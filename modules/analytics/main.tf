# ==============================================================================
#   Access information from parent resources
# ==============================================================================

data "azurerm_resource_group" "parent" {
  name = var.resource_group_name
}

# ==============================================================================
#   Create resources
# ==============================================================================

resource "azurerm_log_analytics_workspace" "main" {
  count               = var.enabled ? 1 : 0
  # --
  name                = "${var.prefix}-LogAnalyticsWorkspace-${var.postfix}"
  location            = data.azurerm_resource_group.parent.location
  resource_group_name = data.azurerm_resource_group.parent.name
  # --
  sku               = var.sku               #"PerGB2018"
  retention_in_days = var.retention_in_days #30
}

resource "azurerm_log_analytics_solution" "main" {
  count               = var.enabled ? 1 : 0
  # --
  location            = data.azurerm_resource_group.parent.location
  resource_group_name = data.azurerm_resource_group.parent.name
  # --
  solution_name         = "ContainerInsights"
  workspace_resource_id = azurerm_log_analytics_workspace.main[0].id
  workspace_name        = azurerm_log_analytics_workspace.main[0].name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
