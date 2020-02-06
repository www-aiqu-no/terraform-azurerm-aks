# ==============================================================================
#   Deploy AKS cluster
# ==============================================================================

# Create new resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-${var.resource_group_name}"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "main" {
  #count = var.initialized ? 1 : 0 # Required due to manually granting permissions
  name = "${var.prefix}-${var.kube_name}-${random_string.postfix.result}"
  # --
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  # --
  dns_prefix         = "${var.dns_prefix}-${random_string.postfix.result}"
  kubernetes_version = var.kube_version
  tags               = var.kube_tags

  # See https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#default_node_pool
  default_node_pool {
    name            = var.pool_name
    type            = var.pool_vm_type
    vm_size         = var.pool_vm_size
    node_count      = var.pool_vm_count
    os_disk_size_gb = var.pool_vm_disk_size

    # Required for advanced networking -- TODO
    #vnet_subnet_id  = azurerm_subnet.aks.id
  }

  linux_profile {
    admin_username = var.admin_user
    ssh_key {
      key_data = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh[0].public_key_openssh
    }
  }

  # Advanced networking. See https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md
  network_profile {
    network_plugin = "azure"

    # See https://docs.microsoft.com/en-us/azure/aks/load-balancer-standard
    load_balancer_sku = "basic"
  }

  service_principal {
    client_id     = azuread_application.client.application_id
    client_secret = azuread_service_principal_password.client.value
  }

  role_based_access_control {
    enabled = true

    # Pre-Generated credentials
    azure_active_directory {
      client_app_id     = azuread_application.client.application_id
      server_app_id     = azuread_application.server.application_id
      server_app_secret = azuread_service_principal_password.server.value
    }
  }

  addon_profile {
    # See https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-solution-template-kubernetes-dashboard?view=azs-1910
    kube_dashboard {
      enabled = true
    }

    oms_agent {
      enabled                    = var.log_analytics_enabled
      log_analytics_workspace_id = var.log_analytics_enabled ? azurerm_log_analytics_workspace.main[0].id : null
    }

    # See https://docs.microsoft.com/en-us/azure/aks/http-application-routing
    http_application_routing {
      enabled = false
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# ==============================================================================
#  Configure Azure AD integration (RBAC)
# ==============================================================================

# Create the Azure AD Server application
resource "azuread_application" "server" {
  name = "${var.prefix}-Server"

  type                    = "webapp/api"
  reply_urls              = ["https://www.kred.no"]
  group_membership_claims = "All"

  # Windows Azure Active Directory API
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    # DELEGATED PERMISSION: "Sign in and read user profile"
    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  # MicrosoftGraph API permissions
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    # APPLICATION PERMISSIONS: "Read directory data"
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }

    # DELEGATED PERMISSIONS: "Sign in and read user profile"
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    # DELEGATED PERMISSIONS: "Read directory data":
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
  }
}

# Create Service Principal ('permission group') for server
resource "azuread_service_principal" "server" {
  application_id = azuread_application.server.application_id
}

# Generate Server Access Credentials
resource "azuread_service_principal_password" "server" {
  service_principal_id = azuread_service_principal.server.id
  value                = random_string.server_password.result
  end_date             = timeadd(timestamp(), "876000h") # 100 years
  lifecycle {
    ignore_changes = [end_date]
  }
}

resource "random_string" "server_password" {
  length  = 16
  special = true
  keepers = {
    service_principal = azuread_service_principal.server.id
  }
}

# ------------------------------------------------------------------------------

# Create RBAC API endpoint application
resource "azuread_application" "client" {
  name = "${var.prefix}-Auth"

  reply_urls = ["https://www.kred.no"]
  type       = "native"

  # Windows Azure Active Directory API
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    # DELEGATED PERMISSION: "Sign in and read user profile"
    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  # AKS AADServer Application
  required_resource_access {
    resource_app_id = azuread_application.server.application_id

    resource_access {
      # AKS Server app Oauth2 permissions id
      id   = lookup(azuread_application.server.oauth2_permissions[0], "id")
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "client" {
  application_id = azuread_application.client.application_id
}

# Create Access Credentials
resource "azuread_service_principal_password" "client" {
  service_principal_id = azuread_service_principal.client.id
  value                = random_string.client_password.result
  end_date             = timeadd(timestamp(), "876000h") # 100 years
  lifecycle {
    ignore_changes = [end_date]
  }
}

resource "azuread_service_principal_password" "self" {
  service_principal_id = azuread_service_principal.client.id
  value                = random_string.self_password.result
  end_date             = timeadd(timestamp(), "876000h") # 100 years
  lifecycle {
    ignore_changes = [end_date]
  }
}

resource "random_string" "client_password" {
  length  = 16
  special = true
  keepers = {
    service_principal = azuread_service_principal.client.id
  }
}

resource "random_string" "self_password" {
  length  = 16
  special = true
  keepers = {
    service_principal = azuread_service_principal.client.id
  }
}

# ==============================================================================
#  OPTIONAL: Log Analytics Solution (log_analytics_enabled = true)
# ==============================================================================

resource "azurerm_log_analytics_workspace" "main" {
  count               = var.log_analytics_enabled ? 1 : 0
  name                = "${var.prefix}-LogAnalyticsWorkspace-${random_string.postfix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  # --
  sku               = var.log_analytics_sku               #"PerGB2018"
  retention_in_days = var.log_analytics_retention_in_days #30
}

resource "azurerm_log_analytics_solution" "main" {
  count               = var.log_analytics_enabled ? 1 : 0
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  # --
  solution_name         = "ContainerInsights"
  workspace_resource_id = azurerm_log_analytics_workspace.main[0].id
  workspace_name        = azurerm_log_analytics_workspace.main[0].name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# ==============================================================================
#   Generate private/public keys, if public key is not provided
# ==============================================================================

resource "tls_private_key" "ssh" {
  count = var.ssh_public_key != "" ? 0 : 1
  # --
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Write private key to disk, if missing
resource "local_file" "private_key" {
  count = var.ssh_public_key != "" ? 0 : 1
  # --
  content  = tls_private_key.ssh[0].private_key_pem
  filename = "./private_ssh_key"
}

# ==============================================================================
#   Create basic & helper resources
# ==============================================================================

resource "random_string" "postfix" {
  length      = 5
  min_lower   = 2
  min_numeric = 2
  lower       = true
  number      = true
  upper       = false
  special     = false
}
