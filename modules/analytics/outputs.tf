output "workspace_id" {
  description = "Analytics Workspace Id"
  sensitive   = false
  value = var.enabled ? azurerm_log_analytics_workspace.main[0].id : null
}
