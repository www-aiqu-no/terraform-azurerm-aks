output "info" {
  description = "Information about working with the cluster"
  value       = <<-EOH
    # To access kubectl on cluster as admin (e.g. to add rbac access):
    $ az aks get-credentials --resource-group <resource-group> --name <cluster-name> --admin
    $ kubectl apply -f rbac-aad-group.yaml
    # To get an kubectl context on the cluster:
    $ az aks get-credentials --resource-group <resource-group> --name <cluster-name>
    # When first using the kubectl command, you will have to use the Azure device login once
    $ kubectl get nodes
  EOH
}

#output "configure" {
#  value = <<-EOH
#    # Run:
#    $ terraform output kub_config > ../aksConfig
#    $ export KUBECONFIG=~../aksConfig
#    $ kubectl get nodes
#  EOH
#}

output "kube_config" {
  description = "Cluster credentials"
  value       = var.cluster_type == "basic" ? module.aks_basic[0].kube_config : module.aks_advanced[0].kube_config
  sensitive   = true
}
