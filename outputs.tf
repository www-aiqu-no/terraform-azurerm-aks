# See README.md regarding module outputs in terraform 0.12+
output "resource_group_name" {
  description = "The name of the resource group"
  sensitive   = false
  value       = module.resource_group.name
}

output "public_ssh_key" {
  description = "The public ssh-key for connecting to nodes in the cluster"
  sensitive   = false
  value       = module.ssh_keys.public_ssh_key
}

output "kube_config" {
  description = "A kube_config block. When Role Based Access Control with Azure Active Directory is enabled, this is exported from kube_admin_config."
  sensitive   = true
  value       = local.aks_kube_config
}

output "log_analytics_solutions_id" {
  description = "The id of the Log Analytics Solutions"
  sensitive   = false
  value       = var.log_analytics_enabled ? module.log_analytics_solution[0].id : ""
}

output "log_analytics_workspace_id" {
  description = "The id of the workspace created for Log Analytics"
  sensitive   = false
  value       = var.log_analytics_enabled ? module.log_analytics_workspace[0].id : null
}

output "log_analytics_workspace_name" {
  description = "The name of the workspace created for Log Analytics"
  sensitive   = false
  value       = var.log_analytics_enabled ? module.log_analytics_workspace[0].name : null
}

output "info" {
  description = "Information about working with the cluster"
  sensitive   = false
  value       = <<-EOH
    # --
    #  Initialized: ${var.initialized} (See README.md for more info)
    # --
    # To access kubectl on cluster as admin (e.g. to add rbac access manually):
    $ az aks get-credentials --resource-group ${module.resource_group.name} --name ${var.prefix}-aks --admin
    # ---
    # To get an kubectl context on the cluster (first add permissions):
    $ az aks get-credentials --resource-group ${module.resource_group.name} --name ${var.prefix}-aks
    # ---
    # When first using the kubectl command, you will have to use the Azure device login once
    $ kubectl get nodes
    # ---
    # Authentication (Linux)
    # Run the following commands:
    $ terraform output kube_config > ../aksConfig
    $ export KUBECONFIG=~../aksConfig
    $ kubectl get nodes
  EOH
}

#output "credentials" {
#  description = "Debugging authentication"
#  sensitive   = false
#  value       = <<-EOH
#  Hostname: ${local.aks_host}
#  Certificate: ${local.aks_certificate}
#  Private Key: ${local.aks_key}
#  CA Certificate: ${local.aks_ca_certificate}
#  EOH
#}
