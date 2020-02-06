# See README.md regarding module outputs in terraform 0.12+
# ==============================================================================
#   Non-sensitive (readable by operators)
# ==============================================================================

output "resource_group_name" {
  description = "The name of the resource group"
  sensitive   = false
  value       = azurerm_resource_group.main.name
}

output "public_ssh_key" {
  description = "The public ssh-key for connecting to nodes in the cluster"
  sensitive   = false
  value       = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh[0].public_key_openssh
}

output "application_id_server" {
  description = "Application id of the application server"
  sensitive   = false
  value       = azuread_application.server.application_id
}

output "application_id_client" {
  description = "Application id of the application client"
  sensitive   = false
  value       = azuread_application.client.application_id
}

# ------------------------------------------------------------------------------

output "info" {
  description = "Information about working with the cluster"
  sensitive   = false
  value = <<-EOH
    # --
    #  See README.md for more info
    # --
    # To access kubectl on cluster as admin (e.g. to add rbac access manually):
    $ az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name} --admin
    # ---
    # To get an kubectl context on the cluster (first add permissions):
    $ az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}
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

# ==============================================================================
#   Sensitive (for internal use by terraform)
# ==============================================================================

output "kube_config" {
  description = "A kube_config block. When Role Based Access Control with Azure Active Directory is enabled, this is exported from kube_admin_config."
  sensitive   = true
  value       = azurerm_kubernetes_cluster.main.kube_config
}

output "kube_admin_config" {
  description = "A kube_config block. When Role Based Access Control with Azure Active Directory is enabled, this is exported from kube_admin_config."
  sensitive   = true
  value       = azurerm_kubernetes_cluster.main.kube_admin_config
}

# ==============================================================================
#   Debugging
# ==============================================================================
