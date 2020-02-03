resource "azurerm_log_analytics_solution" "main" {
  count                 = var.enabled ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = var.log_analytics_workspace_id
  workspace_name        = var.log_analytics_workspace_name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
