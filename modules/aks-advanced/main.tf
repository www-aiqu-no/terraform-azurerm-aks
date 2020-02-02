resource "azurerm_kubernetes_cluster" "main" {
  count = var.enabled ? 1 : 0
  name                = "${var.prefix}-aks"
  resource_group_name = var.resource_group_name
  location            = var.location

  dns_prefix          = "${var.prefix}-dns"
  kubernetes_version  = var.k8s_version
  tags                = var.tags

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
    client_id     = var.appid_client
    client_secret = var.spid_client_secret
  }

  role_based_access_control {
    enabled = true

    # Pre-Generated credentials
    azure_active_directory {
      client_app_id     = var.appid_client
      server_app_id     = var.appid_server
      server_app_secret = var.spid_server_secret
    }
  }

  addon_profile {
    # See https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-solution-template-kubernetes-dashboard?view=azs-1910
    kube_dashboard {
      enabled = true
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
}
