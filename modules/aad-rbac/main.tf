#
# See https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration?view=azure-cli-latest
#
resource "azuread_application" "server" {
  count = var.enabled ? 1 : 0
  name = "${var.prefix}-RBAC-Server"

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

resource "azuread_application" "client" {
  count = var.enabled ? 1 : 0
  name = "${var.prefix}-RBAC-Client"

  reply_urls              = ["https://www.kred.no"]
  type                    = "native"
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

  # AKS server
  required_resource_access {
    resource_app_id = azuread_application.server[0].application_id

    resource_access {
      # AKS Server app Oauth2 permissions id
      id   = lookup(azuread_application.server[0].oauth2_permissions[0], "id")
      type = "Scope"
    }
   }
}

resource "azuread_application" "self" {
  count = var.enabled ? 1 : 0
  name = "${var.prefix}-RBAC-Self"

  reply_urls              = ["https://www.kred.no"]
  type                    = "native"
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

  # AKS server
  required_resource_access {
    resource_app_id = azuread_application.server[0].application_id

    resource_access {
      # AKS Server app Oauth2 permissions id
      id   = lookup(azuread_application.server[0].oauth2_permissions[0], "id")
      type = "Scope"
    }
   }
}

# ------------------------------------------------------------------------------

resource "azuread_service_principal" "server" {
  count = var.enabled ? 1 : 0
  application_id = azuread_application.server[0].application_id
}

resource "azuread_service_principal" "client" {
  count = var.enabled ? 1 : 0
  application_id = azuread_application.client[0].application_id
}

resource "azuread_service_principal" "self" {
  count = var.enabled ? 1 : 0
  application_id = azuread_application.self[0].application_id
}

# ------------------------------------------------------------------------------

# See https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations
#   The end date will change at each run (terraform apply), causing a new password to
#   be set. So we ignore changes on this field in the resource lifecyle to avoid this
#   behaviour.
#
#   If the desired behaviour is to change the end date, then the resource must be
#   manually tainted.
resource "azuread_service_principal_password" "server" {
  count = var.enabled ? 1 : 0
  service_principal_id = azuread_service_principal.server[0].id
  value                = random_string.application_server_password[0].result
  end_date             = timeadd(timestamp(), "876000h") # 100 years

  lifecycle {
    ignore_changes = [end_date]
  }
}

resource "azuread_service_principal_password" "client" {
  count = var.enabled ? 1 : 0
  service_principal_id = azuread_service_principal.client[0].id
  value                = random_string.application_client_password[0].result
  end_date             = timeadd(timestamp(), "876000h") # 100 years

  lifecycle {
    ignore_changes = [end_date]
  }
}

resource "azuread_service_principal_password" "self" {
  count = var.enabled ? 1 : 0
  service_principal_id = azuread_service_principal.self[0].id
  value                = random_string.application_self_password[0].result
  end_date             = timeadd(timestamp(), "876000h") # 100 years

  lifecycle {
    ignore_changes = [end_date]
  }
}

# ------------------------------------------------------------------------------

# See https://www.terraform.io/docs/providers/random/r/string.html#keepers
#   Generate new id if sp changes
resource "random_string" "application_server_password" {
  count = var.enabled ? 1 : 0
  length  = 16
  special = true

  keepers = {
    service_principal = azuread_service_principal.server[0].id
  }
}

resource "random_string" "application_client_password" {
  count = var.enabled ? 1 : 0
  length  = 16
  special = true

  keepers = {
    service_principal = azuread_service_principal.client[0].id
  }
}

resource "random_string" "application_self_password" {
  count = var.enabled ? 1 : 0
  length  = 16
  special = true

  keepers = {
    service_principal = azuread_service_principal.self[0].id
  }
}
