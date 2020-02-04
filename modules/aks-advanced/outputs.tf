output "kube_config" {
  description = "A kube_config block"
  sensitive   = true
  value       = var.enabled ? azurerm_kubernetes_cluster.main[0].kube_config : null
}

output "kube_admin_config" {
  description = "A kube_admin_config block as defined below. This is only available when Role Based Access Control with Azure Active Directory is enabled."
  sensitive   = true
  value       = var.enabled ? azurerm_kubernetes_cluster.main[0].kube_admin_config : null
}

output "host" {
  description = "The Kubernetes cluster server host."
  sensitive   = true
  value       = var.enabled ? azurerm_kubernetes_cluster.main[0].kube_config[0].host : null
}

output "username" {
  description = "A username used to authenticate to the Kubernetes cluster."
  sensitive   = true
  value       = var.enabled ? azurerm_kubernetes_cluster.main[0].kube_config[0].username : null
}

output "password" {
  description = "A password or token used to authenticate to the Kubernetes cluster."
  sensitive   = true
  value       = var.enabled ? azurerm_kubernetes_cluster.main[0].kube_config[0].password : null
}

output "client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster."
  sensitive   = true
  value       = var.enabled ? base64decode(azurerm_kubernetes_cluster.main[0].kube_config[0].client_certificate) : null
}

output "client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the Kubernetes cluster."
  sensitive   = true
  value       = var.enabled ? base64decode(azurerm_kubernetes_cluster.main[0].kube_config[0].client_key) : null
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster."
  sensitive   = true
  value       = var.enabled ? base64decode(azurerm_kubernetes_cluster.main[0].kube_config[0].cluster_ca_certificate) : null
}
