# ==============================================================================
#   FROM PARENT MODULE
# ==============================================================================
variable "resource_group_name" {}
variable "prefix" {}
# --
variable "kube_name" {}
variable "kube_version" {}
variable "kube_dns_prefix" {}
variable "kube_tags" {}
# --
variable "pool_name" {}
variable "pool_vm_type" {}
variable "pool_vm_size" {}
variable "pool_vm_count" {}
variable "pool_vm_disk_size" {}
variable "pool_auto_scaling_enabled" {}
variable "pool_auto_scaling_max" {}
variable "pool_auto_scaling_min" {}
# --
variable "admin_user" {}
variable "ssh_public_key" {}
# --
variable "client_id" {}
variable "client_secret" {}
variable "server_id" {}
variable "server_secret" {}
# --
variable "log_analytics_enabled" {}
variable "log_analytics_workspace_id" {}
