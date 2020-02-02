output "client_id" {
  description = ""
  value       = var.enabled ? azuread_application.main[0].application_id : null
}

output "client_secret" {
  description = ""
  sensitive   = true
  value       = var.enabled ? azuread_service_principal_password.main[0].value : null
}
