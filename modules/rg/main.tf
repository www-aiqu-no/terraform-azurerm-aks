# Description
#   This sub-module will create a new resource-group for the deployment
#   If the 'enable' is false, then it will just return the name & location as is
resource "azurerm_resource_group" "main" {
  count = var.enabled ? 1 : 0
  # --
  name     = var.name
  location = var.location
}

data "azurerm_resource_group" "main" {
  count = var.enabled ? 0 : 1
  # --
  name     = var.name
}
