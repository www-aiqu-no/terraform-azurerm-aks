# ==============================================================================
#   Resource Group & helper functions
# ==============================================================================

# Lookup resource group (Issue #9: Not created in module due to submodule dependencies)
data "azurerm_resource_group" "main" {
  name     = "${var.prefix}-${var.resource_group_name}"
  #location = var.location
}

# Create random postfix string
resource "random_string" "postfix" {
  length      = 5
  min_lower   = 2
  min_numeric = 2
  # --
  lower   = true
  number  = true
  upper   = false
  special = false
}

# ==============================================================================
#  Deploy AKS Cluster
# ==============================================================================

module "aks" {
  source              = "./modules/aks"
  resource_group_name = data.azurerm_resource_group.main.name
  # --
  prefix  = var.prefix
  # --
  kube_name       = var.kube_name
  kube_version    = var.kube_version
  kube_dns_prefix = var.kube_dns_prefix != "" ? var.kube_dns_prefix : "dns-${random_string.postfix.result}"
  kube_tags       = var.kube_tags
  # --
  pool_name         = var.pool_name
  pool_vm_type      = var.pool_vm_type
  pool_vm_size      = var.pool_vm_size
  pool_vm_count     = var.pool_vm_count
  pool_vm_disk_size = var.pool_vm_disk_size
  # --
  pool_auto_scaling_enabled = var.pool_auto_scaling_enabled
  pool_auto_scaling_max     = var.pool_auto_scaling_max
  pool_auto_scaling_min     = var.pool_auto_scaling_min
  # --
  admin_user     = var.admin_user
  ssh_public_key = module.ssh.ssh_public_key
  # --
  client_id     = module.aad.client_id
  client_secret = module.aad.client_secret
  server_id     = module.aad.server_id
  server_secret = module.aad.server_secret
  # --
  log_analytics_enabled      = var.log_analytics_enabled
  log_analytics_workspace_id = module.analytics.workspace_id
}

# ==============================================================================
#  Configure Azure AD integration (RBAC)
# ==============================================================================

module "aad" {
  source = "./modules/aad"
  # --
  prefix  = var.prefix
}

# ==============================================================================
#  Configure Advanced Networking
# ==============================================================================

#module "network" {
#  source = "./modules/ssh"
#}

# ==============================================================================
#  OPTIONAL: Log Analytics Solution (log_analytics_enabled = true)
# ==============================================================================

module "analytics" {
  source              = "./modules/analytics"
  resource_group_name = data.azurerm_resource_group.main.name
  # --
  prefix            = var.prefix
  postfix           = random_string.postfix.result
  enabled           = var.log_analytics_enabled
  sku               = var.log_analytics_sku
  retention_in_days = var.log_analytics_retention_in_days
}

# ==============================================================================
#   Generate private/public keys, if public key is not provided
# ==============================================================================

module "ssh" {
  source  = "./modules/ssh"
  # --
  ssh_public_key = var.ssh_public_key
}
