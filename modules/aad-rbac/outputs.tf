output "appid_server" {
  description = "Application Id for the aks application"
  value       = var.enabled ? azuread_application.aks[0].application_id : null
}

output "appid_client" {
  description = "Application Id for the aks rbac client application"
  value       = var.enabled ? azuread_application.rbac_client[0].application_id : null
}

output "spid_server_secret" {
  description = "Credentials from the aks application"
  sensitive   = true
  value       = var.enabled ? azuread_service_principal_password.aks[0].value : null
}

output "spid_client_secret" {
  description = "Credentials from the aks rbac application"
  sensitive   = true
  value       = var.enabled ? azuread_service_principal_password.self[0].value : null
}
