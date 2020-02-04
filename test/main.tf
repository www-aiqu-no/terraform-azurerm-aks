# ==============================================================================
#   Terraform Settings
# ==============================================================================

terraform {
  required_version = ">= 0.12"
  #experiments = [variable_validation]
}

# Just for creating random name(s) during testing
resource "random_string" "prefix" {
  length  = 4
  special = false
}

# Deployment

module "testing_advanced" {
  source       = "../."
  prefix       = random_string.prefix.result
  cluster_type = "advanced"
  #initialized  = true

  log_analytics_enabled   = true
  kube_management_enabled = true
  kube_dashboard_as_admin = true
  #kube_admin_group = "<Group Id or Name>"
}

# NOTE: To print output from modules, you need to export it in root:
output "kube_info" {
  value = module.testing_advanced.info
}

output "kube_public_ssh_key" {
  value = module.testing_advanced.public_ssh_key
}
