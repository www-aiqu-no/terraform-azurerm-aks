# ==============================================================================
#   Required providers
#   The version numbers are the ones used when developing the role
# ==============================================================================
terraform {
  required_version = ">= 0.12"
  #TODO: experiments = [variable_validation]

  required_providers {
    azurerm = "~> 1.42"
    azuread = "~> 0.7"
    random  = "~> 2.2"
    local   = "~> 1.4"
    tls     = "~> 2.1"
    # This is added in sub-module 'kube-modules', with authentication from deployment
    #kubernetes = "~> 1.10"
  }
}

provider "kubernetes" {
  version                = "~> 1.10"
  host                   = local.aks_host
  client_certificate     = local.aks_certificate    # KUBE_CLIENT_CERT_DATA
  client_key             = local.aks_key            # KUBE_CLIENT_KEY_DATA
  cluster_ca_certificate = local.aks_ca_certificate # KUBE_CLUSTER_CA_CERT_DATA
  #load_config_file       = true # KUBE_LOAD_CONFIG_FILE
  #config_path            = "~/.kube/config" # KUBE_CONFIG
  #username               = var.kube_config.0.username
  #password               = var.kube_config.0.password
}
