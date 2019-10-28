resource "kubernetes_service" "editor-renderer_service" {
  metadata {
    name      = "editor-renderer-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.editor-renderer_deployment.metadata[0].labels.app
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "editor-renderer_deployment" {
  metadata {
    name      = "editor-renderer-app"
    namespace = var.namespace

    labels = {
      app = "editor-renderer"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "editor-renderer"
      }
    }

    template {
      metadata {
        labels = {
          app = "editor-renderer"
        }
      }

      spec {
        container {
          image             = var.image
          name              = "editor-renderer-container"
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

provider "kubernetes" {
  version = "~> 1.8"
}
