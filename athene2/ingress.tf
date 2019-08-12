resource "kubernetes_ingress" "athene2_ingress" {
  metadata {
    name      = "athene2-ingress"
    namespace = var.namespace

    annotations = merge(
      { "kubernetes.io/ingress.class" = "nginx" },
      var.enable_basic_auth ? {
        "nginx.ingress.kubernetes.io/auth-type"   = "basic"
        "nginx.ingress.kubernetes.io/auth-secret" = "basic-auth-ingress-secret"
        "nginx.ingress.kubernetes.io/auth-realm"  = "Authentication Required"
      } : {}
    )
  }

  spec {
    backend {
      service_name = var.varnish_service_name
      service_port = var.varnish_service_port
    }
  }
}

resource "kubernetes_secret" "basic_auth_ingress_secret" {
  count = var.enable_basic_auth ? 1 : 0

  metadata {
    name      = "basic-auth-ingress-secret"
    namespace = var.namespace
  }

  data = {
    auth = "serloteam:$apr1$L6BuktMk$qfh8xvsWsPi3uXB0fIiu1/"
  }
}
