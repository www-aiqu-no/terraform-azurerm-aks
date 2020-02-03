resource "kubernetes_cluster_role_binding" "roles" {
  count = var.enabled ? 1 : 0

  metadata {
    name = "cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = var.admin_group #"b6605286-5d3c-4f9e-8701-b98208b84c6b"
  }
}
