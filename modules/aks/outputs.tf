output "info" {
  description = "Information about working with the cluster"
  sensitive   = false
  value       = <<-EOH
    # --
    #  See README.md for more info
    # --
    # To access kubectl on cluster as admin (e.g. to add rbac access manually):
    $ az aks get-credentials --resource-group ${data.azurerm_resource_group.parent.name} --name ${azurerm_kubernetes_cluster.main.name} --admin
    # ---
    # To get an kubectl context on the cluster (first add permissions):
    $ az aks get-credentials --resource-group ${data.azurerm_resource_group.parent.name} --name ${azurerm_kubernetes_cluster.main.name}
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
