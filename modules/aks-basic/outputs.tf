output "kube_config" {
  value = azurerm_kubernetes_cluster.main[0].kube_config
}
