resource "kubernetes_service" "legacy-editor-renderer_service" {
  metadata {
    name      = "legacy-editor-renderer-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.legacy-editor-renderer_deployment.metadata[0].labels.app
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "legacy-editor-renderer_deployment" {
  metadata {
    name      = "legacy-editor-renderer-app"
    namespace = var.namespace

    labels = {
      app = "legacy-editor-renderer"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "legacy-editor-renderer"
      }
    }

    template {
      metadata {
        labels = {
          app = "legacy-editor-renderer"
        }
      }

      spec {
        container {
          image             = "eu.gcr.io/serlo-shared/serlo-org-legacy-editor-renderer:${var.image_tag}"
          name              = "legacy-editor-renderer-container"
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
