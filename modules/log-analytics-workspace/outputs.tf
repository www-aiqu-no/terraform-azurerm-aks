output "id" {
  description = "The id of the workspace created for Log Analytics"
  value       = var.enabled ? azurerm_log_analytics_workspace.main[0].id : null
}

output "name" {
  description = "The name of the workspace created for Log Analytics"
  value       = var.enabled ? azurerm_log_analytics_workspace.main[0].name : null
}
