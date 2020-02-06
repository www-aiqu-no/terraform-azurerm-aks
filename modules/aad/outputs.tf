output "server_id" {
  description = "Application id for server application"
  sensitive   = false
  value       = azuread_application.server.application_id
}

output "client_id" {
  description = "Application id for client (rbac) application"
  sensitive   = false
  value       = azuread_application.client.application_id
}

output "server_secret" {
  description = "credentials for accessing server application"
  sensitive   = true
  value       = azuread_service_principal_password.server.value
}

output "client_secret" {
  description = "credentials for accessing client (rbac) application"
  sensitive   = true
  value       = azuread_service_principal_password.client.value
}
