resource "kubernetes_service" "frontend_service" {
  metadata {
    name      = "frontend-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.frontend_deployment.metadata[0].labels.app
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "frontend_deployment" {
  metadata {
    name      = "frontend-app"
    namespace = var.namespace

    labels = {
      app = "frontend"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          image             = "eu.gcr.io/serlo-shared/serlo-org-frontend:${var.image_tag}"
          name              = "frontend-container"
          image_pull_policy = var.image_pull_policy

          env {
            name  = "NEXT_ASSET_PREFIX"
            value = "https://packages.serlo.org/serlo-org-frontend-assets@${var.image_tag}"
          }

          env {
            name  = "ASSET_PREFIX"
            value = "https://packages.serlo.org/serlo-org-frontend-assets@${var.image_tag}"
          }

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
