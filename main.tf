module "resource_group" {
  source   = "./modules/resource-group"
  enabled  = var.resource_group_name != "" ? false : true
  prefix   = var.prefix
  location = var.location
}

module "ssh_keys" {
  source = "./modules/ssh-keys"
  enabled = var.ssh_public_key != "" ? false : true
}

# ==============================================================================
#  Deploy basic AKS cluster
#    Use: Set variable 'cluster_type' to 'basic' (default)
# ==============================================================================

module "service_principals_basic" {
  source  = "./modules/aad-basic"
  enabled = (var.appid_client != "") && (var.cluster_type == "basic") ? false : true
  prefix  = var.prefix
}

module "aks_basic" {
  source              = "./modules/aks-basic"
  enabled             = var.cluster_type == "basic" ? true : false
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : module.resource_group.name
  ssh_public_key      = var.ssh_public_key      != "" ? var.ssh_public_key      : module.ssh_keys.public_ssh_key
  client_id           = var.spid_client         != "" ? var.spid_client         : module.service_principals_basic.appid
  client_secret       = var.spid_client_secret  != "" ? var.spid_client_secret  : module.service_principals_basic.spid_secret
}

# ==============================================================================
#  Deploy advanced AKS cluster (rbac & cni enabled)
#    Use: Set variable 'cluster_type' to 'advanced'
# ==============================================================================

module "service_principals_rbac" {
  source  = "./modules/aad-rbac"
  enabled = var.cluster_type == "advanced" ? true : false
  prefix  = var.prefix
}

module "aks_advanced" {
  source              = "./modules/aks-advanced"
  enabled             = var.cluster_type == "advanced" ? true : false
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : module.resource_group.name
  ssh_public_key      = var.ssh_public_key      != "" ? var.ssh_public_key      : module.ssh_keys.public_ssh_key
  appid_server        = var.appid_server        != "" ? var.appid_server        : module.service_principals_rbac.appid_server
  appid_client        = var.appid_client        != "" ? var.appid_client        : module.service_principals_rbac.appid_client
  appid_self          = var.appid_self          != "" ? var.appid_self          : module.service_principals_rbac.appid_self
  spid_server_secret  = var.spid_server_secret  != "" ? var.spid_server_secret  : module.service_principals_rbac.spid_server_secret
  spid_self_secret    = var.spid_self_secret    != "" ? var.spid_self_secret    : module.service_principals_rbac.spid_self_secret
}
