output "kube_config" {
  description = ""
  sensitive   = true
  value       = var.enabled ? azurerm_kubernetes_cluster.main[0].kube_config : null
}
