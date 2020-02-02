resource "azurerm_log_analytics_workspace" "main" {
  count               = var.enabled ? 1 : 0
  name                = "${var.prefix}-log-analytics-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_retention_in_days
}
