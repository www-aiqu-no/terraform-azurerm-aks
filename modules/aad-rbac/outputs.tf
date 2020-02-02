output "appid_server" {
  description = ""
  value       = var.enabled ? azuread_application.aks[0].id : null
}

output "appid_rbac_client" {
  description = ""
  value       = var.enabled ? azuread_application.rbac[0].id : null
}

output "spid_server_secret" {
  description = ""
  sensitive   = true
  value       = var.enabled ? azuread_service_principal_password.aks[0].value : null
}

output "spid_self_secret" {
  description = ""
  sensitive   = true
  value       = var.enabled ? azuread_service_principal_password.self[0].value : null
}
