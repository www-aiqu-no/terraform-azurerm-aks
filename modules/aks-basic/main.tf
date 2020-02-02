resource "azurerm_kubernetes_cluster" "main" {
  count = var.enabled ? 1 : 0

  name                = "${var.prefix}-aks"
  dns_prefix          = var.dns_prefix

  resource_group_name = var.resource_group_name
  location            = var.location

  kubernetes_version = var.k8s_version
  tags = {
    "Deployment" = "Terraform Module"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  # See https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#default_node_pool
  default_node_pool {
    name                  = var.pool_name
    vm_size               = var.pool_vm_size
    type                  = var.pool_vm_type
    node_count            = var.pool_vm_count
    os_disk_size_gb       = var.pool_vm_disk_size
    enable_auto_scaling   = var.pool_auto_scaling
    enable_node_public_ip = false
  }

  linux_profile {
    admin_username = var.admin_user
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  role_based_access_control {
    enabled = false
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
