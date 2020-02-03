# ==============================================================================
#   Required providers
# ==============================================================================
#provider "azurerm"    { version = "~> 1.42" }
#provider "azuread"    { version = "~> 0.7"  }
#provider "random"     { version = "~> 2.2"  }
#provider "local"      { version = "~> 1.4"  }
#provider "tls"        { version = "~> 2.1"  }

# This is added in sub-module, with authentication from deployment
#provider "kubernetes" { version = "~> 1.10" }

# ==============================================================================
#   Create required resources, if not provided
# ==============================================================================

module "resource_group" {
  source   = "./modules/resource-group"
  enabled  = (var.resource_group_override != "") ? false : true
  prefix   = var.prefix
  location = var.location
}

module "ssh_keys" {
  source = "./modules/ssh-keys"
  enabled = (var.ssh_public_key != "") ? false : true
}

# ==============================================================================
#  Deploy 'basic' AKS cluster
#    > cluster_type = basic (default)
# ==============================================================================

module "service_principals_basic" {
  source         = "./modules/aad-basic"
  enabled        = (var.cluster_type == "basic") ? true : false
  prefix         = var.prefix
}

module "aks_basic" {
  source                = "./modules/aks-basic"
  enabled               = (var.initialized && var.cluster_type == "basic") ? true : false
  prefix                = var.prefix
  location              = var.location
  resource_group_name   = var.resource_group_override != "" ? var.resource_group_override : module.resource_group.name
  client_id             = var.appid_client            != "" ? var.appid_client            : module.service_principals_basic.client_id
  client_secret         = var.spid_client_secret      != "" ? var.spid_client_secret      : module.service_principals_basic.client_secret
  ssh_public_key        = var.ssh_public_key          != "" ? var.ssh_public_key          : module.ssh_keys.public_ssh_key
  admin_user            = var.admin_user
  kube_version          = var.kube_version
  tags                  = var.tags
  dns_prefix            = var.dns_prefix
  pool_name             = var.pool_name
  pool_vm_type          = var.pool_vm_type
  pool_vm_size          = var.pool_vm_size
  pool_vm_disk_size     = var.pool_vm_disk_size
  pool_vm_count         = var.pool_vm_count
  pool_auto_scaling     = var.pool_auto_scaling
  log_analytics_enabled = var.log_analytics_enabled
  log_analytics_workspace_id = module.log_analytics_workspace.id
}

# ==============================================================================
#  Deploy 'advanced' AKS cluster (rbac & cni enabled)
#    > cluster_type = advanced
# ==============================================================================

module "service_principals_rbac" {
  source  = "./modules/aad-rbac"
  enabled = var.cluster_type == "advanced" ? true : false
  prefix  = var.prefix
}

module "aks_advanced" {
  source                = "./modules/aks-advanced"
  enabled               = (var.initialized && var.cluster_type == "advanced") ? true : false
  prefix                = var.prefix
  location              = var.location
  resource_group_name   = var.resource_group_override != "" ? var.resource_group_override : module.resource_group.name
  appid_server          = var.appid_server            != "" ? var.appid_server            : module.service_principals_rbac.appid_server
  appid_client          = var.appid_client            != "" ? var.appid_client            : module.service_principals_rbac.appid_client
  spid_server_secret    = var.spid_server_secret      != "" ? var.spid_server_secret      : module.service_principals_rbac.spid_server_secret
  spid_client_secret    = var.spid_client_secret      != "" ? var.spid_client_secret      : module.service_principals_rbac.spid_client_secret
  ssh_public_key        = var.ssh_public_key          != "" ? var.ssh_public_key          : module.ssh_keys.public_ssh_key
  admin_user            = var.admin_user
  kube_version          = var.kube_version
  tags                  = var.tags
  dns_prefix            = var.dns_prefix
  pool_name             = var.pool_name
  pool_vm_type          = var.pool_vm_type
  pool_vm_size          = var.pool_vm_size
  pool_vm_disk_size     = var.pool_vm_disk_size
  pool_vm_count         = var.pool_vm_count
  pool_auto_scaling     = var.pool_auto_scaling
  log_analytics_enabled = var.log_analytics_enabled
  log_analytics_workspace_id = module.log_analytics_workspace.id
}

# ==============================================================================
#  Deploy Log Analytics Solution
#    > log_analytics_enabled = true
# ==============================================================================

module "log_analytics_workspace" {
  source                      = "./modules/log-analytics-workspace"
  enabled                     = (var.initialized && var.log_analytics_enabled) ? true : false
  prefix                      = var.prefix
  location                    = var.location
  resource_group_name         = var.resource_group_override != "" ? var.resource_group_override : module.resource_group.name
  log_analytics_workspace_sku = var.log_analytics_workspace_sku
  log_retention_in_days       = var.log_retention_in_days
}

module "log_analytics_solution" {
  source                       = "./modules/log-analytics-solution"
  enabled                      = (var.initialized && var.log_analytics_enabled) ? true : false
  prefix                       = var.prefix
  location                     = var.location
  resource_group_name          = var.resource_group_override != "" ? var.resource_group_override : module.resource_group.name
  log_analytics_workspace_id   = module.log_analytics_workspace.id
  log_analytics_workspace_name = module.log_analytics_workspace.name
}

# ==============================================================================
#   OPTIONAL: Configure the deployed cluster
#     > kube_management_enabled = true
# ==============================================================================
module "kube_management" {
  source      = "./modules/kube-modules"
  enabled     = var.kube_management_enabled ? true : false
  kube_config = var.cluster_type == "advanced" ? module.aks_advanced.kube_config : module.aks_basic.kube_config
  admin_group = var.kube_admin_group
}
