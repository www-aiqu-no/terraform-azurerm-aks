resource "azurerm_kubernetes_cluster" "main" {
  count = var.enabled ? 1 : 0

  name                = "${var.prefix}-aks"
  resource_group_name = var.resource_group_name
  location            = var.location != "" ? var.location : data.azurerm_resource_group.self.location
  dns_prefix          = "${var.prefix}-dns"
  kubernetes_version  = var.k8s_version

  tags = {
    "Deployment" = "Terraform Module"
  }

  # See https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#default_node_pool
  default_node_pool {
    name            = var.pool_name
    type            = var.pool_vm_type
    vm_size         = var.pool_vm_size
    node_count      = var.pool_vm_count
    os_disk_size_gb = var.pool_vm_disk_size

    # Required for advanced networking
    #vnet_subnet_id  = azurerm_subnet.aks.id
  }

  linux_profile {
    admin_username = var.admin_user
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  # Advanced networking. See https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md
  network_profile {
    network_plugin = "azure"

    # See https://docs.microsoft.com/en-us/azure/aks/load-balancer-standard
    load_balancer_sku = "basic"
  }

  service_principal {
    client_id     = var.appid_self #azuread_application.self.application_id
    client_secret = var.spid_self_secret #azuread_service_principal_password.self.value
  }

  role_based_access_control {
    enabled = false

    # Pre-Generated credentials (See README.md)
    azure_active_directory {
      server_app_id     = var.appid_server #azuread_application.aks_server.application_id
      client_app_id     = var.appid_client #azuread_application.aks_client.application_id
      server_app_secret = var.spid_server_secret #azuread_service_principal_password.aks_server.value
    }
  }

  addon_profile {
    # See https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-solution-template-kubernetes-dashboard?view=azs-1910
    kube_dashboard {
      enabled = true
    }
    oms_agent {
      enabled = false
    }
    # See https://docs.microsoft.com/en-us/azure/aks/http-application-routing
    http_application_routing {
      enabled = false
    }
  }
}
