# ==============================================================================
#   Terraform Settings & helpers
# ==============================================================================

terraform {
  required_version = ">= 0.12"

  required_providers {
    azurerm = "~> 1.42"
    azuread = "~> 0.7"
    random  = "~> 2.2"
    local   = "~> 1.4"
    tls     = "~> 2.1"
  }
}

# Just for creating random name(s) during testing
resource "random_string" "prefix" {
  length  = 5
  special = false
}

# ==============================================================================
#   Deploy module (current)
# ==============================================================================

module "aks_test" {
  source = "../."
  prefix = random_string.prefix.result
  # --
  initialized           = true
  log_analytics_enabled = false
}

# ==============================================================================
#   Outputs from module needs to be exported
# ==============================================================================

# NOTE: To print output from modules, you need to export it in root:
output "kube_info" {
  value = module.aks_test.info
}

output "kube_public_ssh_key" {
  value = module.aks_test.public_ssh_key
}

# ==============================================================================
#   Check Connection
# ==============================================================================

provider "kubernetes" {
  host                   = cluster.kube_host
  client_certificate     = base64decode(module.cluster.kube_client_certificate)
  client_key             = base64decode(module.cluster.kube_client_key)
  cluster_ca_certificate = base64decode(module.cluster.kube_cluster_ca_certificate)
}

resource "kubernetes_cluster_role_binding" "dashboard_cluster_admin" {
  count = var.initialized ? 1 : 0

  metadata {
    name = "dashboard-cluster-admin"
  }

  # Specify which role to assign
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin" # pre-defined
  }

  # Assign specified role to subjects
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard" # pre-defined
    namespace = "kube-system"
  }
}
