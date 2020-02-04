# ==============================================================================
#   AKS Cluster Configuration
# ==============================================================================

# NOTE: Use of this sub-module requires the tf-executor to have the following
#       permission(s) in azure ad: "Microsoft.Authorization/roleAssignments/*"
#       See README.md for example .json
module "role_bindings" {
  source             = "./role-bindings"
  enabled            = var.enabled ? true : false
  admin_group        = var.admin_group
  dashboard_as_admin = var.dashboard_as_admin
}
