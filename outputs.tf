# See README.md regarding module outputs in terraform 0.12+
# ==============================================================================
#   Non-sensitive (readable by operators)
# ==============================================================================

output "ssh_public_key" {
  description = "The public ssh-key for connecting to nodes in the cluster"
  sensitive   = false
  value       = module.ssh.ssh_public_key
}

# ------------------------------------------------------------------------------

output "info" {
  description = "Information about working with the cluster"
  sensitive   = false
  value       = module.aks.info
}

# ==============================================================================
#   Sensitive (for internal use by terraform)
# ==============================================================================

output "kube_config" {
  description = "A kube_config block. When Role Based Access Control with Azure Active Directory is enabled, this is exported from kube_admin_config."
  sensitive   = true
  value       = module.aks.kube_config
}

output "kube_admin_config" {
  description = "A kube_config block. When Role Based Access Control with Azure Active Directory is enabled, this is exported from kube_admin_config."
  sensitive   = true
  value       = module.aks.kube_admin_config
}

# ==============================================================================
#   Debugging
# ==============================================================================
