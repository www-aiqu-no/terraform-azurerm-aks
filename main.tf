# ==============================================================================
#   Define local variables
# ==============================================================================

locals {
  # AKS settings used by kubernetes provider internally (See versions.tf)
  # Used since we have 2 types of clusters to select correct output, and the
  # output kube_config values/hash can't be set to null
  aks_kube_config    = !(var.initialized) ? null : var.cluster_type == "advanced" ? module.aks_advanced.kube_admin_config[0]                                      : module.aks_basic.kube_config[0]
  aks_host           = !(var.initialized) ? ""   : var.cluster_type == "advanced" ? module.aks_advanced.kube_admin_config[0].host                                 : module.aks_basic.kube_config[0].host
  aks_certificate    = !(var.initialized) ? ""   : var.cluster_type == "advanced" ? base64decode(module.aks_advanced.kube_admin_config[0].client_certificate)     : base64decode(module.aks_basic.kube_config[0].client_certificate)
  aks_key            = !(var.initialized) ? ""   : var.cluster_type == "advanced" ? base64decode(module.aks_advanced.kube_admin_config[0].client_key)             : base64decode(module.aks_basic.kube_config[0].client_key)
  aks_ca_certificate = !(var.initialized) ? ""   : var.cluster_type == "advanced" ? base64decode(module.aks_advanced.kube_admin_config[0].cluster_ca_certificate) : base64decode(module.aks_basic.kube_config[0].cluster_ca_certificate)
}

# ==============================================================================
#   Create required resources, if not provided
# ==============================================================================

# Create new resource group if one is not provided (override)
module "resource_group" {
  source   = "./modules/resource-group"
  enabled  = (var.resource_group_override != "") ? false : true
  prefix   = var.prefix
  location = var.location
}

# Generate private/public keys if public key is not provided
module "ssh_keys" {
  source = "./modules/ssh-keys"
  enabled = (var.ssh_public_key != "") ? false : true
}

# ==============================================================================
#  Deploy Log Analytics Solution
#    > log_analytics_enabled = true
# ==============================================================================

module "log_analytics_workspace" {
  source              = "./modules/log-analytics-workspace"
  enabled             = (var.log_analytics_enabled) ? true : false
  prefix              = var.prefix
  resource_group_name = var.resource_group_override != "" ? var.resource_group_override : module.resource_group.name
  location            = var.location
  # --
  log_analytics_workspace_sku = var.log_analytics_workspace_sku
  log_retention_in_days       = var.log_retention_in_days
}

module "log_analytics_solution" {
  source              = "./modules/log-analytics-solution"
  enabled             = (var.log_analytics_enabled) ? true : false
  prefix              = var.prefix
  resource_group_name = var.resource_group_override != "" ? var.resource_group_override : module.resource_group.name
  location            = var.location
  # --
  log_analytics_workspace_id   = module.log_analytics_workspace.id
  log_analytics_workspace_name = module.log_analytics_workspace.name
}

# ==============================================================================
#  Deploy 'basic' AKS cluster
#    > cluster_type = basic (default)
# ==============================================================================

# Create basic Azure AD application
module "service_principals_basic" {
  source         = "./modules/aad-basic"
  enabled        = (var.cluster_type == "basic") ? true : false
  prefix         = var.prefix
}

module "aks_basic" {
  source              = "./modules/aks-basic"
  enabled             = (var.initialized && var.cluster_type == "basic") ? true : false
  prefix              = var.prefix
  resource_group_name = var.resource_group_override != "" ? var.resource_group_override : module.resource_group.name
  location            = var.location
  client_id           = var.appid_client            != "" ? var.appid_client            : module.service_principals_basic.client_id
  client_secret       = var.spid_client_secret      != "" ? var.spid_client_secret      : module.service_principals_basic.client_secret
  ssh_public_key      = var.ssh_public_key          != "" ? var.ssh_public_key          : module.ssh_keys.public_ssh_key
  admin_user          = var.admin_user
  kube_version        = var.kube_version
  tags                = var.tags
  dns_prefix          = var.dns_prefix
  pool_name           = var.pool_name
  pool_vm_type        = var.pool_vm_type
  pool_vm_size        = var.pool_vm_size
  pool_vm_disk_size   = var.pool_vm_disk_size
  pool_vm_count       = var.pool_vm_count
  pool_auto_scaling   = var.pool_auto_scaling
  # --
  log_analytics_enabled      = var.log_analytics_enabled
  log_analytics_workspace_id = module.log_analytics_workspace.id
}

# ==============================================================================
#  Deploy 'advanced' AKS cluster (rbac & cni enabled)
#    > cluster_type = advanced
# ==============================================================================

# Create RBAC integration in Azure AD
module "service_principals_rbac" {
  source  = "./modules/aad-rbac"
  enabled = var.cluster_type == "advanced" ? true : false
  prefix  = var.prefix
}

module "aks_advanced" {
  source              = "./modules/aks-advanced"
  enabled             = (var.initialized && var.cluster_type == "advanced") ? true : false
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_override != "" ? var.resource_group_override : module.resource_group.name
  appid_server        = var.appid_server            != "" ? var.appid_server            : module.service_principals_rbac.appid_server
  appid_client        = var.appid_client            != "" ? var.appid_client            : module.service_principals_rbac.appid_client
  spid_server_secret  = var.spid_server_secret      != "" ? var.spid_server_secret      : module.service_principals_rbac.spid_server_secret
  spid_client_secret  = var.spid_client_secret      != "" ? var.spid_client_secret      : module.service_principals_rbac.spid_client_secret
  ssh_public_key      = var.ssh_public_key          != "" ? var.ssh_public_key          : module.ssh_keys.public_ssh_key
  admin_user          = var.admin_user
  kube_version        = var.kube_version
  tags                = var.tags
  dns_prefix          = var.dns_prefix
  pool_name           = var.pool_name
  pool_vm_type        = var.pool_vm_type
  pool_vm_size        = var.pool_vm_size
  pool_vm_disk_size   = var.pool_vm_disk_size
  pool_vm_count       = var.pool_vm_count
  pool_auto_scaling   = var.pool_auto_scaling
  # --
  log_analytics_enabled      = var.log_analytics_enabled
  log_analytics_workspace_id = module.log_analytics_workspace.id
}

# ==============================================================================
#   OPTIONAL: Configure the deployed cluster
#     > kube_management_enabled = true
# ==============================================================================

module "kube_management" {
  source             = "./modules/kube-modules"
  enabled            = (var.initialized && var.kube_management_enabled )? true : false
  admin_group        = var.kube_admin_group
  dashboard_as_admin = var.kube_dashboard_as_admin
}
