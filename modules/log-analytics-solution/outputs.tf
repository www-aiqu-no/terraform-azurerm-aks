output "id" {
  description = "The id of the Log Analytics Solutions"
  value       = var.enabled ? azurerm_log_analytics_solution.main[0].id : ""
}
