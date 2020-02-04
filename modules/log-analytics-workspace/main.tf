resource "azurerm_log_analytics_workspace" "main" {
  count               = var.enabled ? 1 : 0
  name                = "${var.prefix}-log-analytics-workspace-${random_string.postfix[0].result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_retention_in_days
}

# See https://www.terraform.io/docs/providers/random/r/string.html#keepers
#   Generate new id if sp changes
resource "random_string" "postfix" {
  count       = var.enabled ? 1 : 0
  length      = 5
  min_lower   = 2
  min_numeric = 2
  lower       = true
  number      = true
  upper       = false
  special     = false
}
