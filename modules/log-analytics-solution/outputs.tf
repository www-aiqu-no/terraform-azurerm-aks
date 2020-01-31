output "id" {
  value = var.enabled ? azurerm_log_analytics_solution.main.id : ""
}
