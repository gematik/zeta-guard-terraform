resource "kubernetes_namespace" "postgres_operator" {
  metadata {
    name = "postgres-operator"
    labels = {
      "app.kubernetes.io/name" = "postgres-operator"
    }
  }
}

resource "helm_release" "postgres_operator" {
  name             = "postgres-operator"
  repository       = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator/"
  chart            = "postgres-operator"
  # TODO: latest version?
  version          = "1.11.0"
  namespace        = kubernetes_namespace.postgres_operator.metadata[0].name
  atomic           = true

  # To restrict, supply values with watched_namespace and/or label selectors.
  # values = [yamlencode({
  #   configGeneral = {
  #     watched_namespace = "*"  # default
  #   }
  # })]
}
