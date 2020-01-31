# ==============================================================================
#   Terraform Settings
# ==============================================================================

terraform {
  required_version = ">= 0.12"
  #experiments = [variable_validation]
}

# ==============================================================================
#   Providers
# ==============================================================================

provider "azurerm"    { version = "~> 1.42" }
provider "azuread"    { version = "~> 0.7"  }
provider "random"     { version = "~> 2.2"  }
provider "local"      { version = "~> 1.4"  }
provider "tls"        { version = "~> 2.1"  }

# ==============================================================================
#   Modules Settings
# ==============================================================================

resource "random_string" "prefix" {
  length  = 4
  special = false
}

module "testing" {
  #source       = "github.com/www-aiqu-no/terraform-azurerm-aks?ref=master"
  source       = "../."
  prefix       = random_string.prefix.result
  cluster_type = "advanced"
  initialized  = false
}

provider "kubernetes" {
  version                = "~> 1.10"
  host                   = module.testing.kube_config.0.host
  username               = module.testing.kube_config.0.username
  password               = module.testing.kube_config.0.password
  client_certificate     = base64decode(module.testing.kube_config.0.client_certificate)
  client_key             = base64decode(module.testing.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(module.testing.kube_config.0.cluster_ca_certificate)
}
