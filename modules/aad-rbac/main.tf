#
# See https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration?view=azure-cli-latest

# This is the aad aks application
resource "azuread_application" "aks" {
  count = var.enabled ? 1 : 0
  name  = "${var.prefix}-aks"

  type                    = "webapp/api"
  reply_urls              = ["https://www.kred.no"]
  group_membership_claims = "All"

  # Windows Azure Active Directory API
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    # DELEGATED PERMISSION: "Sign in and read user profile"
    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  # MicrosoftGraph API permissions
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    # APPLICATION PERMISSIONS: "Read directory data"
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }

    # DELEGATED PERMISSIONS: "Sign in and read user profile"
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    # DELEGATED PERMISSIONS: "Read directory data":
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
  }
}

# Service principal ('permission group') for users
resource "azuread_service_principal" "aks" {
  count = var.enabled ? 1 : 0
  application_id = azuread_application.aks[0].application_id
}

# Access Credentials to SP
resource "azuread_service_principal_password" "aks" {
  count = var.enabled ? 1 : 0
  service_principal_id = azuread_service_principal.aks[0].id
  value                = random_string.aks_password[0].result
  end_date             = timeadd(timestamp(), "876000h") # 100 years

  lifecycle {
    ignore_changes = [end_date]
  }
}

resource "random_string" "aks_password" {
  count = var.enabled ? 1 : 0
  length  = 16
  special = true

  keepers = {
    service_principal = azuread_service_principal.aks[0].id
  }
}

# ------------------------------------------------------------------------------

# This is the rbac API endpoint for rbac-users
resource "azuread_application" "rbac_client" {
  count = var.enabled ? 1 : 0
  name = "${var.prefix}-rbac"

  reply_urls = ["https://www.kred.no"]
  type       = "native"

  # Windows Azure Active Directory API
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    # DELEGATED PERMISSION: "Sign in and read user profile"
    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  # AKS server
  required_resource_access {
    resource_app_id = azuread_application.aks[0].application_id

    resource_access {
      # AKS Server app Oauth2 permissions id
      id   = lookup(azuread_application.aks[0].oauth2_permissions[0], "id")
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "rbac_client" {
  count = var.enabled ? 1 : 0
  application_id = azuread_application.rbac_client[0].application_id
}

# Cluster credentials
resource "azuread_service_principal_password" "self" {
  count = var.enabled ? 1 : 0
  service_principal_id = azuread_service_principal.rbac_client[0].id
  value                = random_string.rbac_self_password[0].result
  end_date             = timeadd(timestamp(), "876000h") # 100 years

  lifecycle {
    ignore_changes = [end_date]
  }
}

resource "random_string" "rbac_self_password" {
  count = var.enabled ? 1 : 0
  length  = 16
  special = true

  keepers = {
    service_principal = azuread_service_principal.rbac_client[0].id
  }
}

# ------------------------------------------------------------------------------

# See https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations
#   The end date will change at each run (terraform apply), causing a new password to
#   be set. So we ignore changes on this field in the resource lifecyle to avoid this
#   behaviour.
#
#   If the desired behaviour is to change the end date, then the resource must be
#   manually tainted.

# See https://www.terraform.io/docs/providers/random/r/string.html#keepers
#   Generate new id if sp changes
