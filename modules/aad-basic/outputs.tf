output "appid" {
  sensitive = false
  value     = var.enabled ? azuread_application.main[0].id : ""
}

output "spid" {
  sensitive = false
  value     = var.enabled ? azuread_service_principal.main[0].id : ""
}

output "spid_secret" {
  sensitive = true
  value     = var.enabled ? azuread_service_principal_password.main[0].value : ""
}
