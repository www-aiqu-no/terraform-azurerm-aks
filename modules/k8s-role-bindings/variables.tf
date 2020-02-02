# ==============================================================================
#   REQUIRED (passed from parent module)
# ==============================================================================
variable "enabled"     { description = "Do we create a new resource group?" }
variable "prefix"      { description = "Prefix for all the resources" }
variable "admin_group" { description = "Azure group-id for administrators" }
