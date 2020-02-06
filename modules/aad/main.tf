# ==============================================================================
#   Create AAD Applications
# ==============================================================================

# Server application
resource "azuread_application" "server" {
  name = "${var.prefix}-Server"

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

# RBAC endpoint
resource "azuread_application" "client" {
  name = "${var.prefix}-Auth"

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

  # AKS AADServer Application
  required_resource_access {
    resource_app_id = azuread_application.server.application_id

    resource_access {
      # AKS Server app Oauth2 permissions id
      id   = lookup(azuread_application.server.oauth2_permissions[0], "id")
      type = "Scope"
    }
  }
}

# ==============================================================================
#   Create permission groups ("Service Principals")
# ==============================================================================

resource "azuread_service_principal" "server" {
  application_id = azuread_application.server.application_id
}

resource "azuread_service_principal" "client" {
  application_id = azuread_application.client.application_id
}

# ==============================================================================
#   Create credentials ("Service Principal Passwords")
# ==============================================================================

resource "azuread_service_principal_password" "server" {
  service_principal_id = azuread_service_principal.server.id
  value                = random_string.server_password.result
  end_date             = timeadd(timestamp(), "876000h") # 100 years
  lifecycle {
    ignore_changes = [end_date]
  }
}

resource "azuread_service_principal_password" "client" {
  service_principal_id = azuread_service_principal.client.id
  value                = random_string.client_password.result
  end_date             = timeadd(timestamp(), "876000h") # 100 years
  lifecycle {
    ignore_changes = [end_date]
  }
}

# ==============================================================================
#   Create random passwords for use in credentials
# ==============================================================================

resource "random_string" "server_password" {
  length  = 16
  special = true
  keepers = {
    service_principal = azuread_service_principal.server.id
  }
}

resource "random_string" "client_password" {
  length  = 16
  special = true
  keepers = {
    service_principal = azuread_service_principal.client.id
  }
}
