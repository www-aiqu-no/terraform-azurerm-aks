# ==============================================================================
#   REQUIRED (from parent module)
# ==============================================================================

variable "enabled" {
  description = "The prefix for the resources created in the specified Azure Resource Group."
}

variable "prefix" {
  description = "The prefix for the resources created in the specified Azure Resource Group."
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the resources"
}

variable "location" {
  description = "The Azure Region in which to create the resources"
}

# ------------------------------------------------------------------------------

variable "ssh_public_key" {
  description = "The SSH key to be used for the username defined in the `admin_username` variable."
  default     = ""
}

# ------------------------------------------------------------------------------

variable "appid_server"       {}
variable "appid_client"       {}
variable "appid_self"         {}
variable "spid_server_secret" {}
variable "spid_self_secret"   {}
#variable "spid_server" {}
#variable "spid_client" {}
#variable "spid_self"   {}
#variable "spid_client_secret"  {}

# ==============================================================================
#   OPTIONAL (from parent module)
# ==============================================================================

variable "k8s_version" {
  description = "Version of kubernetes to deploy"
  default     = "1.15.7"
}

variable "tags" {
  description = "Any tags that should be present on the Virtual Network resources"
  type        = map(string)
  default     = {}
}

variable "admin_user" {
  description = "The username of the local administrator to be created on the Kubernetes cluster"
  default     = "azure"
}

variable "log_analytics_workspace_id" {
  description = "The Log Analytics Workspace Id."
  default     = ""
}

variable "dns_prefix" {
  description = ""
  default     = "aks"
}

# ------------------------------------------------------------------------------

variable "pool_name" {
  description = "Name of the default VM pool"
  default     = "default"
}

variable "pool_vm_type" {
  description = "Type of VMs in the default pool"
  default     = "VirtualMachineScaleSets"
}

variable "pool_vm_size" {
  description = "Size of VMs in the default pool"
  default     = "Standard_DS2_v2"
}

variable "pool_vm_count" {
  description = "Number of VMs in the default pool"
  default     = 2
}

variable "pool_auto_scaling" {
  description = "Enable automatic scaling of the default pool"
  default     = false
}

variable "pool_vm_disk_size" {
  description = "DiskSize for VMs in the default pool"
  default     = 30
}
