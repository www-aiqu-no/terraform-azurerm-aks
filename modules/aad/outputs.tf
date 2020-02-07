output "aks_id" {
  description = "Application id for AKS"
  sensitive   = false
  value       = azuread_application.server.application_id
}

output "server_id" {
  description = "Application id for Azure AD integration"
  sensitive   = false
  value       = azuread_application.server.application_id
}

output "client_id" {
  description = "Application id for excternal client access application (CLI)"
  sensitive   = false
  value       = azuread_application.client.application_id
}

# --

output "aks_secret" {
  description = "Credentials for use by cluster"
  sensitive   = true
  value       = azuread_service_principal_password.server.value
}

output "server_secret" {
  description = "Credentials for accessing Azure AD"
  sensitive   = true
  value       = azuread_service_principal_password.server.value
}

output "client_secret" {
  description = "Credentials for accessing client (cli) application"
  sensitive   = true
  value       = azuread_service_principal_password.client.value
}
