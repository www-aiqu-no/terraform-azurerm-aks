output "name" {
  description = "Returns the name of the resource-group to use"
  sensitive   = false
  value       = var.enabled ? azurerm_resource_group.main[0].name : data.azurerm_resource_group.main[0].name
}

output "location" {
  description = "Returns the location of the resource-group to use"
  sensitive   = false
  value       = var.enabled ? azurerm_resource_group.main[0].location : data.azurerm_resource_group.main[0].location
}
