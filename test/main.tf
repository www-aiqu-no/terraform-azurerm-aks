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

module "cluster" {
  source = "../."
  prefix = random_string.prefix.result
}

# ==============================================================================
#   Outputs from module needs to be exported if you want to see them
# ==============================================================================

# NOTE: To print output from modules, you need to export it in root:
output "kube_info" {
  value = module.cluster.info
}

output "kube_ssh_public_key" {
  value = module.cluster.ssh_public_key
}

# ==============================================================================
#   Check Connection / use credentials for configuring the deployed cluster
# ==============================================================================

# Set values; just for readability
locals {
  # Retrieve (sensitive) values from the aks-module
  host                   = module.cluster.kube_admin_config[0].host
  username               = module.cluster.kube_admin_config[0].username
  password               = module.cluster.kube_admin_config[0].password
  client_certificate     = base64decode(module.cluster.kube_admin_config[0].client_certificate)
  client_key             = base64decode(module.cluster.kube_admin_config[0].client_key)
  cluster_ca_certificate = base64decode(module.cluster.kube_admin_config[0].cluster_ca_certificate)

  # Set other values
  kube_dashboard_as_admin = true
}

# Use credentials for connecting to the cluster
provider "kubernetes" {
  host                   = local.host
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
}

# Allow dashboard user to manage all resources (potentially insecure!)
resource "kubernetes_cluster_role_binding" "dashboard_cluster_admin" {
  count = local.kube_dashboard_as_admin ? 1 : 0

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
    namespace = "kube-system"          # v1 dashboard
  }
}
