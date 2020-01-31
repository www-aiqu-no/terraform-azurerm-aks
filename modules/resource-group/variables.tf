# ==============================================================================
#   REQUIRED (passed from main module)
# ==============================================================================
variable "enabled" {
  description = "Do we create a new resource group?"
}

variable "prefix" {
  description = "Prefix for all the resources"
}

variable "location" {
  description = "Where to create the resource group"
}

variable "resource_group_name" {
  description = "Name of the resource group to use"
}

# ==============================================================================
#   OPTIONAL (passed from main module)
# ==============================================================================
