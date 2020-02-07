# ==============================================================================
#   Resource Group & helper functions
# ==============================================================================

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
#  Create/validate resource-group
# ==============================================================================

# Lookup resource group (Issue #9: Not created in module due to submodule dependencies)
#resource "azurerm_resource_group" "main" {
#  name     = var.resource_group_name
#  location = var.location
#}

# Outputs:
#   - name, location
module "resource_group" {
  source  = "./modules/rg"
  enabled = var.resource_group_create
  # --
  name     = var.resource_group_name
  location = var.location
}

# ==============================================================================
#  Deploy AKS Cluster
# ==============================================================================

# Outputs:
#   - info, kube_config, kube_admin_config
module "aks" {
  source              = "./modules/aks"
  resource_group_name = module.resource_group.name #azurerm_resource_group.main.name
  location            = module.resource_group.location #azurerm_resource_group.main.location
  # --
  prefix  = var.prefix
  # --
  kube_name              = var.kube_name
  kube_version           = var.kube_version
  kube_dashboard_enabled = var.kube_dashboard_enabled
  kube_dns_prefix        = var.kube_dns_prefix != "" ? var.kube_dns_prefix : "dns-${random_string.postfix.result}"
  kube_tags              = var.kube_tags
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
  aks_id        = module.aad.aks_id
  aks_secret    = module.aad.aks_secret
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

# Outputs:
#   - server_id, client_id, server_secret, client_secret
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

# Outputs:
#   - workspace_id
module "analytics" {
  source              = "./modules/analytics"
  resource_group_name = module.resource_group.name #azurerm_resource_group.main.name
  location            = module.resource_group.location #azurerm_resource_group.main.location
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

# Outputs:
#   - ssh_public_key
module "ssh" {
  source  = "./modules/ssh"
  # --
  ssh_public_key = var.ssh_public_key
}
