# ROLE VARIABLES

# ==============================================================================
#   OPTIONAL
#   - This is where you customize your cluster
# ==============================================================================

variable "initialized" {
  description = "[MANUAL] 'Admin Concent' granted for applications in Azure"
  default     = false
}

variable "cluster_type" {
  description = "The type of cluster you want to deploy (basic/advanced)"
  default     = "basic"

  # Experimental
  #validation {
  #  condition     = contains(["basic","advanced"], var.cluster_type)
  #  error_message = "Valid options are [basic, advanced]."
  #}
}

variable "prefix" {
  description = "Prefix for any resources created in the resource group"
  default     = "aks"
}

# NOTE: $ az account list-locations --output table
variable "location" {
  description = "Datacenter location for this deployment. Use 'az account list-locations --output table' to get a full list"
  default     = "eastus"
}

variable "resource_group_override" {
  description = "Use an existing resource group. No value (default) creates a new resource group"
  default     = ""
}

# ------------------------------------------------------------------------------

variable "k8s_version" {
  description = "Version of kubernetes to deploy"
  default     = "1.15.7"
}

variable "ssh_public_key" {
  description = "SSH-key for accessing linux nodes in the cluster. No value will create local private key to disk, and use the public key for cluster"
  default     = ""
}

variable "admin_user" {
  description = "The Local Administrator for linux nodes in the cluster"
  default     = "aks"
}

# NOTE: The dns_prefix must contain between 3 and 45 characters, and can contain only letters, numbers, and hyphens. It must start with a letter and must end with a letter or a number.
variable "dns_prefix" {
  description = "DNS prefix (required to be unique)"
  default     = "AksDns"
}

variable "tags" {
  description = "Version of kubernetes to deploy"
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

variable "appid_server" {
  description = "AppicationId to use for the k8s application. No value creates new application"
  default     = ""
}

variable "appid_client" {
  description = "AppicationId to use for the k8s-rbac application. No value creates new application"
  default     = ""
}

#variable "spid_server" {
#  description = "Service principal for managing the server application"
#  default     = ""
#}

#variable "spid_client" {
#  description = "Service principal for clients"
#  default     = ""
#}

#variable "spid_self" {
#  description = "Service principal for cluster"
#  default     = ""
#}

variable "spid_server_secret" {
  description = "Credentials for accessing k8s application (server)"
  default     = ""
}

variable "spid_client_secret" {
  description = "Credentials for accessing k8s application (clients)"
  default     = ""
}

variable "spid_self_secret" {
  description = "Credentials for accessing k8s application (cluster)"
  default     = ""
}

# ------------------------------------------------------------------------------

variable "use_log_analytics" {
  description = "Configure ContainerInsights (analytics)"
  default     = false
}

# ------------------------------------------------------------------------------

# Configure network profile (advanced networking)
# See https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md
variable "use_azure_cni" {
  description = "Configure Azure network plugin (cni)"
  default     = false
}

# ------------------------------------------------------------------------------

variable "configure_k8s_roles" {
  description = "Configure cluster roles"
  default     = false
}

variable "aad_k8s_admin_group" {
  description = "k8s administrator group in azure aad"
  default     = "00000000-0000-0000-0000-000000000000"
}
