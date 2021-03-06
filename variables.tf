# ==============================================================================
#   OPTIONAL
#   - This is where you customize your cluster deployment
# ==============================================================================

variable "prefix" {
  description = "Prefix for any resources created for this module"
  default     = "aks"
}

variable "resource_group_name" {
  description = "Name of new resource group in Azure (prefix get added)"
  default     = "resources"
}

# NOTE: $ az account list-locations --output table
# Examples: norwaywest, norwayeast, ..
variable "location" {
  description = "Datacenter location for this deployment. Use 'az account list-locations --output table' to get a full list"
  default     = "eastus"
}

# ------------------------------------------------------------------------------

variable "kube_name" {
  description = "Name of the kubernetes cluster"
  default     = "primary"
}

variable "kube_version" {
  description = "Version of kubernetes to deploy"
  default     = "1.15.7"
}

variable "admin_user" {
  description = "The Local Administrator for linux nodes in the cluster"
  default     = "aks"
}

variable "ssh_public_key" {
  description = "SSH-key for accessing linux nodes in the cluster. No value will create local private key to disk, and use the public key for cluster"
  default     = ""
}

# NOTE: The dns_prefix must contain between 3 and 45 characters, and can contain only letters, numbers, and hyphens. It must start with a letter and must end with a letter or a number.
variable "dns_prefix" {
  description = "DNS prefix (required to be unique). Must contain between 3 and 45 characters, and can contain only letters, numbers, and hyphens. It must start with a letter and must end with a letter or a number."
  default     = "AksDns"
}

variable "kube_tags" {
  description = "Tags to add to the cluster"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------

variable "pool_name" {
  description = "Name of the default node pool"
  default     = "default"
}

variable "pool_vm_type" {
  description = "Type of VMs in the default node pool"
  default     = "VirtualMachineScaleSets"
}

variable "pool_vm_size" {
  description = "Size of VMs in the default node pool"
  default     = "Standard_DS2_v2"
}

variable "pool_vm_count" {
  description = "Number of VMs in the default node pool"
  default     = 1
}

variable "pool_auto_scaling" {
  description = "Enable autoscaling for default pool"
  default     = false
}

# NOTE: Minimum size is 30
variable "pool_vm_disk_size" {
  description = "Size of disk on VMs in the default node pool"
  default     = 30
}

# ------------------------------------------------------------------------------

variable "log_analytics_enabled" {
  description = "Configure ContainerInsights (analytics)"
  default     = false
}

variable "log_analytics_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace"
  default     = "PerGB2018"
}

variable "log_analytics_retention_in_days" {
  description = "The retention period for the logs in days"
  default     = 30
}

# ------------------------------------------------------------------------------

# Configure network profile (advanced networking)
# See https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md
#variable "use_azure_cni" {
#  description = "Configure Azure network plugin (cni)"
#  default     = false
#}

# ==============================================================================
#   OPTIONAL
#   - Customize roles in the deployed cluster
# ==============================================================================

#variable "kube_dashboard_as_admin" {
#  description = "Make the dashboard ServiceAccount cluster administrtor (potentially insecure)"
#  default     = false
#}

#variable "kube_aad_admin_group" {
#  description = "Make members of Azure AAD group kube administrators"
#  default     = "" #"00000000-0000-0000-0000-000000000000"
#}
