resource "kubernetes_service" "matomo_service" {
  metadata {
    name      = "matomo-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.matomo_deployment.metadata[0].labels.app
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_deployment" "matomo_deployment" {
  metadata {
    name      = "matomo-app"
    namespace = var.namespace

    labels = {
      app = "matomo"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "matomo"
      }
    }

    template {
      metadata {
        labels = {
          app = "matomo"
        }
      }

      spec {
        container {
          image             = "matomo:${var.image_tag}"
          name              = "matomo-container"
          image_pull_policy = var.image_pull_policy

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }

            initial_delay_seconds = 5
            period_seconds        = 30
          }

          resources {
            limits {
              cpu    = var.container_limits_cpu
              memory = var.container_limits_memory
            }

            requests {
              cpu    = var.container_requests_cpu
              memory = var.container_requests_memory
            }
          }
        }
      }
    }
  }
}
