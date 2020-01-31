output "name" {
  # Only output if resource is created
  value = var.enabled ? azurerm_resource_group.main[0].name : ""
}
