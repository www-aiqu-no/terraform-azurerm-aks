output "appid_server" {
  sensitive = false
  value     = var.enabled ? azuread_application.server[0].id : ""
}

output "appid_client" {
  sensitive = false
  value     = var.enabled ? azuread_application.client[0].id : ""
}

output "appid_self" {
  sensitive = false
  value     = var.enabled ? azuread_application.self[0].id : ""
}

# ------------------------------------------------------------------------------

output "spid_server" {
  sensitive = false
  value     = var.enabled ? azuread_service_principal.server[0].id : ""
}

output "spid_client" {
  sensitive = false
  value     = var.enabled ? azuread_service_principal.client[0].id : ""
}

output "spid_self" {
  sensitive = false
  value     = var.enabled ? azuread_service_principal.self[0].id : ""
}

# ------------------------------------------------------------------------------

output "spid_server_secret" {
  sensitive = true
  value     = var.enabled ? azuread_service_principal_password.server[0].value : ""
}

#output "spid_client_secret" {
#  sensitive = true
#  value     = var.enabled ? azuread_service_principal_password.client[0].value : ""
#}

output "spid_self_secret" {
  sensitive = true
  value     = var.enabled ? azuread_service_principal_password.self[0].value : ""
}
