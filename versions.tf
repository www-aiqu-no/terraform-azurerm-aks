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
  }
}
