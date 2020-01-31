# Description ..
resource "azurerm_resource_group" "main" {
  count    = var.enabled ? 1 : 0
  location = var.location != "" ? var.location : data.azurerm_subscription.current.location_placement_id
  name     = "${var.prefix}-${var.resource_group_name}"
}
