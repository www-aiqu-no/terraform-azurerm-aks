output "id" {
  value = var.enabled ? azurerm_log_analytics_workspace.main.id : ""
}

output "name" {
  value = var.enabled ? azurerm_log_analytics_workspace.main.name : ""
}
