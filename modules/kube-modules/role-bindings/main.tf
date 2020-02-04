# ==============================================================================
# Bind specific AAD Group to cluster-administrator role
# ==============================================================================

resource "kubernetes_cluster_role_binding" "cluster_admin" {
  count = (var.enabled && var.admin_group != "") ? 1 : 0

  metadata {
    name = "admins"
  }

  # Specify which role to assign
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin" # pre-defined
  }

  # Assign specified role to subjects
  subject {
    kind      = "ServiceAccount"
    name      = "default" # pre-defined
    namespace = "kube-system"
  }

  #
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = var.admin_group
  }
}

# ------------------------------------------------------------------------------

resource "kubernetes_cluster_role_binding" "dashboard_cluster_admin" {
  count = (var.enabled && var.dashboard_as_admin) ? 1 : 0

  metadata {
    name = "dashboard-cluster-admin"
  }

  # Specify which role to assign
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin" # pre-defined
  }

  # Assign specified role to subjects
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard" # pre-defined
    namespace = "kube-system"
  }
}
