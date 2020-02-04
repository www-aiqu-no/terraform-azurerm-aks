# TODO: Try to output name from resource. Problem w/empty tuple
output "name" {
  description = "Name of the resource group to use"
  #value       = var.enabled ? azurerm_resource_group.main[count.index].name : null
  value       = var.enabled ? "${var.prefix}-Resources" : null
}
