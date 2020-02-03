resource "kubernetes_cluster_role_binding" "roles" {
  count = var.enabled ? 1 : 0

  metadata {
    name = "admins"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
      kind      = "ServiceAccount"
      name      = "default"
      namespace = "kube-system"
    }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = var.admin_group
  }
}
