locals {
  name = "legacy-editor-renderer"
}

variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to use"
  type        = string
}

variable "image_pull_policy" {
  description = "image pull policy"
  type        = string
}

variable "node_pool" {
  type        = string
  description = "Node pool to use"
}

resource "kubernetes_service" "legacy_editor_renderer" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = local.name
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

output "service_name" {
  value = kubernetes_service.legacy_editor_renderer.spec[0].cluster_ip
}

output "service_uri" {
  value = "http://${kubernetes_service.legacy_editor_renderer.spec[0].cluster_ip}:${kubernetes_service.legacy_editor_renderer.spec[0].port[0].port}"
}

resource "kubernetes_deployment" "legacy_editor_renderer" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    selector {
      match_labels = {
        app = local.name
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        node_selector = {
          "cloud.google.com/gke-nodepool" = var.node_pool
        }

        container {
          image             = "eu.gcr.io/serlo-shared/serlo-org-legacy-editor-renderer:${var.image_tag}"
          name              = local.name
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
              cpu    = "375m"
              memory = "150Mi"
            }

            requests {
              cpu    = "250m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }

  # Ignore changes to number of replicas since we have autoscaling enabled
  lifecycle {
    ignore_changes = [
      spec.0.replicas
    ]
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "legacy_editor_renderer" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  spec {
    max_replicas = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = local.name
    }
  }
}
