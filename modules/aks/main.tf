# ==============================================================================
#   Access information from parent resources
# ==============================================================================

# NOT WORKING
#data "azurerm_resource_group" "parent" {
#  name = var.resource_group_name
#}

# ==============================================================================
#   Create AKS Cluster
# ==============================================================================

resource "azurerm_kubernetes_cluster" "main" {
  name = "${var.prefix}-${var.kube_name}"
  # --
  resource_group_name = var.resource_group_name
  location            = var.location
  # --
  dns_prefix         = var.kube_dns_prefix
  kubernetes_version = var.kube_version
  tags               = var.kube_tags

  # See https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#default_node_pool
  default_node_pool {
    name            = var.pool_name
    type            = var.pool_vm_type
    vm_size         = var.pool_vm_size
    os_disk_size_gb = var.pool_vm_disk_size

    node_count          = var.pool_vm_count
    enable_auto_scaling = var.pool_auto_scaling_enabled
    max_count           = var.pool_auto_scaling_enabled ? var.pool_auto_scaling_max : null # Only used if autoscaling enabled
    min_count           = var.pool_auto_scaling_enabled ? var.pool_auto_scaling_min : null # Only used if autoscaling enabled

    # Required for advanced networking -- TODO
    #vnet_subnet_id  = azurerm_subnet.aks.id
  }

  linux_profile {
    admin_username = var.admin_user
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  # Advanced networking. See https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md
  network_profile {
    network_plugin = "azure"

    # See https://docs.microsoft.com/en-us/azure/aks/load-balancer-standard
    load_balancer_sku = "basic"
  }

  service_principal {
    client_id     = var.client_id # is this correct?
    client_secret = var.client_secret
  }

  role_based_access_control {
    enabled = true

    # Pre-Generated credentials
    azure_active_directory {
      client_app_id     = var.client_id
      server_app_id     = var.server_id
      server_app_secret = var.server_secret
    }
  }

  addon_profile {
    # See https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-solution-template-kubernetes-dashboard?view=azs-1910
    kube_dashboard {
      enabled = var.kube_dashboard_enabled
    }

    oms_agent {
      enabled                    = var.log_analytics_enabled
      log_analytics_workspace_id = var.log_analytics_workspace_id
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
