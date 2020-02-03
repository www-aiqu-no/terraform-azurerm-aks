# Connect to created cluster
provider "kubernetes" {
  version                = "~> 1.10"
  host                   = var.kube_config.0.host
  #username               = var.kube_config.0.username
  #password               = var.kube_config.0.password
  client_certificate     = base64decode(var.kube_config.0.client_certificate)
  client_key             = base64decode(var.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(var.kube_config.0.cluster_ca_certificate)
}

# ==============================================================================
#  TODO: AKS Cluster Configuration
# ==============================================================================

# NOTE: Use of this sub-module requires the tf-executor to have the following
# permission(s) in azure ad:
#   - "Microsoft.Authorization/roleAssignments/*"
module "role_bindings" {
  source      = "./role-bindings"
  enabled     = (var.enabled && var.admin_group != "") ? true : false
  admin_group = var.admin_group
}
