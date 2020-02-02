resource "azurerm_resource_group" "main" {
  count    = var.enabled ? 1 : 0
  location = var.location
  name     = "${var.prefix}-Resources"
}
