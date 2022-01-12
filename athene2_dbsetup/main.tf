resource "kubernetes_deployment" "dbsetup-cronjob" {
  metadata {
    name      = "dbsetup-cronjob"
    namespace = var.namespace

    labels = {
      app = "content-provider"
    }
  }

  spec {
    replicas = "1"

    selector {
      match_labels = {
        app = "dbsetup"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app  = "dbsetup"
          name = "dbsetup"
        }
      }

      spec {
        node_selector = {
          "cloud.google.com/gke-nodepool" = var.node_pool
        }

        container {
          image             = var.dbsetup_image
          name              = "dbsetup-container"
          image_pull_policy = var.image_pull_policy

          env {
            name  = "GCLOUD_BUCKET_URL"
            value = var.gcloud_bucket_url
          }

          env {
            name  = "GCLOUD_SERVICE_ACCOUNT_NAME"
            value = var.gcloud_service_account_name
          }

          env {
            name = "GCLOUD_SERVICE_ACCOUNT_KEY"
            value_from {
              secret_key_ref {
                key  = "credential.json"
                name = kubernetes_secret.dbsetup_secret.metadata[0].name
              }
            }
          }

          env {
            name  = "ATHENE2_DATABASE_HOST"
            value = var.database_host
          }
          env {
            name  = "ATHENE2_DATABASE_PORT"
            value = "3306"
          }
          env {
            name  = "ATHENE2_DATABASE_USER"
            value = var.database_username_default
          }
          env {
            name = "ATHENE2_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "database-password-default"
                name = kubernetes_secret.dbsetup_secret.metadata[0].name
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "dbsetup_secret" {
  metadata {
    name      = "dbsetup-secret"
    namespace = var.namespace
  }

  data = {
    "database-password-default" = var.database_password_default
    "credential.json"           = var.gcloud_service_account_key
  }

  type = "Opaque"
}
