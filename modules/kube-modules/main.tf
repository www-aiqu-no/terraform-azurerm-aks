# ==============================================================================
#   AKS Cluster Configuration
# ==============================================================================

provider "kubernetes" {
  version                = "~> 1.10"
  host                   = var.enabled ? var.kube_config[0].host : null
  client_certificate     = var.enabled ? base64decode(var.kube_config[0].client_certificate) : null # KUBE_CLIENT_CERT_DATA
  client_key             = var.enabled ? base64decode(var.kube_config[0].client_key) : null # KUBE_CLIENT_KEY_DATA
  cluster_ca_certificate = var.enabled ? base64decode(var.kube_config[0].cluster_ca_certificate) : null # KUBE_CLUSTER_CA_CERT_DATA
  #load_config_file       = true # KUBE_LOAD_CONFIG_FILE
  #config_path            = "~/.kube/config" # KUBE_CONFIG
  #username               = var.kube_config.0.username
  #password               = var.kube_config.0.password
}

# NOTE: Use of this sub-module requires the tf-executor to have the following
#       permission(s) in azure ad: "Microsoft.Authorization/roleAssignments/*"
#       See README.md for example .json
module "role_bindings" {
  source             = "./role-bindings"
  enabled            = var.enabled ? true : false
  admin_group        = var.admin_group
  dashboard_as_admin = var.dashboard_as_admin
}
