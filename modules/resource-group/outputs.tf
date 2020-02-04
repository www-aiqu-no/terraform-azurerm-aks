output "name" {
  description = "Name of the resource group to use"
  value       = var.enabled ? azurerm_resource_group.main[0].name : null
}

output "location" {
  description = "Location of the resource group"
  value       = var.enabled ? azurerm_resource_group.main[0].location : null
}
