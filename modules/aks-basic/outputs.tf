output "kube_config" {
  value = var.enabled ? azurerm_kubernetes_cluster.main[0].kube_config : ""
}
