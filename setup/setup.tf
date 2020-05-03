resource "kubernetes_namespace" "actions-runner-system" {
  metadata {
    name = "actions-runner-system"
  }
}

resource "kubernetes_role" "appdeployer" {
  metadata {
    name = "appdeployer"
    namespace = kubernetes_namespace.actions-runner-system.metadata[0].name
  }
  rule {
    api_groups     = ["apps"]
    resources      = ["deployments"]
    verbs          = ["get", "list", "watch", "create", "update", "patch"]
  }
  rule {
    api_groups     = [""]
    resources      = ["services"]
    verbs          = ["get", "list", "watch", "create", "update", "patch"]
  }
}

resource "kubernetes_role_binding" "appdeployer" {
  metadata {
    name = "appdeployer"
    namespace = kubernetes_namespace.actions-runner-system.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "appdeployer"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = kubernetes_namespace.actions-runner-system.metadata[0].name
  }
}
