# ==============================================================================
#   REQUIRED (passed from parent module)
# ==============================================================================
variable "enabled"             { description = "See parent module" }
variable "prefix"              { description = "See parent module" }
variable "location"            { description = "See parent module" }
variable "resource_group_name" { description = "See parent module" }
# --
variable "k8s_version"    { description = "See parent module" }
variable "ssh_public_key" { description = "See parent module" }
variable "admin_user"     { description = "See parent module" }
variable "dns_prefix"     { description = "See parent module" }
variable "tags"           { description = "See parent module" }
# --
variable "pool_name"         { description = "See parent module" }
variable "pool_vm_type"      { description = "See parent module" }
variable "pool_vm_size"      { description = "See parent module" }
variable "pool_vm_count"     { description = "See parent module" }
variable "pool_auto_scaling" { description = "See parent module" }
variable "pool_vm_disk_size" { description = "See parent module" }
# --
variable "client_id"     { description = "See parent module" }
variable "client_secret" { description = "See parent module" }
# --
variable "log_analytics_enabled"      { description = "See parent module" }
variable "log_analytics_workspace_id" { description = "See parent module" }
