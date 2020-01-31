# ==============================================================================
#   Terraform Settings
# ==============================================================================

terraform {
  required_version = ">= 0.12"
}

# ==============================================================================
#   Providers
# ==============================================================================

provider "azurerm" { version = "~> 1.42" }
provider "azuread" { version = "~> 0.7"  }
provider "random"  { version = "~> 2.2"  }
provider "local"   { version = "~> 1.4"  }
provider "tls"     { version = "~> 2.1"  }

# ==============================================================================
#   Modules Settings
# ==============================================================================

resource "random_string" "prefix" {
  length  = 4
  special = false
}

module "testing" {
  source       = "../."
  prefix       = random_string.prefix.result
  cluster_type = "advanced"
}
