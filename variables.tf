# ROLE VARIABLES

# ==============================================================================
#   REQUIRED (no defaults)
#   You need to define these parameters for the module to work
# ==============================================================================

# ==============================================================================
#   OPTIONAL
#   This is where you customize your cluster
# ==============================================================================

variable "cluster_type" {
  description = "The type of cluster you want to deploy"
  default     = "basic"
}

variable "resource_group_name" {
  description = "Resource group to create resources in. No value will create a new resource group"
  default     = ""
}

variable "prefix" {
  description = "Prefix for any resources created in the resource group"
  default     = "aks"
}

variable "location" {
  description = "Datacenter location for this deployment"
  default     = ""
}

variable "k8s_version" {
  description = "Version of kubernetes to deploy"
  default     = "1.15.7"
}

# ------------------------------------------------------------------------------

variable "appid_server" { default = "" }
variable "appid_client" { default = "" }
variable "appid_self"   { default = "" }

variable "spid_server" { default = "" }
variable "spid_client" { default = "" }
variable "spid_self"   { default = "" }

variable "spid_server_secret" { default = "" }
variable "spid_client_secret" { default = "" }
variable "spid_self_secret"   { default = "" }

variable "admin_username" {
  description = "The Local Administrator for the AKS cluster"
  default     = "aks"
}

variable "ssh_public_key" {
  description = "SSH-key for accessing nodes in the AKS cluster"
  default     = ""
}

# ------------------------------------------------------------------------------

variable "pool_vm_size" {
  description = "Size of VMs in the default pool"
  default     = "Standard_DS2_v2"
}

variable "pool_vm_count" {
  description = "Number of VMs in the default pool"
  default     = 2
}

# ------------------------------------------------------------------------------

variable "use_log_analytics" {
  description = "Configure ContainerInsights (analytics)"
  default     = false
}

# ------------------------------------------------------------------------------

variable "use_aad_rbac" {
  description = "Configure RBAC for AAD integration"
  default     = false
}

# MANUAL: Grant admin consent manually in the Azure portal for the generated
# aad applications, before setting this to 'true':
#   - <prefix>-RBAC-Server
#   - <prefix>-RBAC-Client
#   - <prefix>-RBAC-Self
variable "aad_rbac_initialized" {
  description = "Version of kubernetes to deploy"
  default     = false
}

# ------------------------------------------------------------------------------

# Configure network profile (advanced networking)
# See https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md
variable "use_azure_cni" {
  description = "Configure Azure network plugin (cni)"
  default     = false
}
