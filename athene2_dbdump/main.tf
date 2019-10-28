
resource "kubernetes_deployment" "dbdump-cronjob" {
  metadata {
    name      = "dbdump-cronjob"
    namespace = var.namespace

    labels = {
      app = "dbdump"
    }
  }

  spec {
    replicas = "1"

    selector {
      match_labels = {
        app = "dbdump"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app  = "dbdump"
          name = "dbdump"
        }
      }

      spec {
        container {
          image             = var.dbdump_image
          name              = "dbdump-container"
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
                name = kubernetes_secret.dbdump_secret.metadata[0].name
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
            value = var.database_username_readonly
          }
          env {
            name = "ATHENE2_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "database-password-readonly"
                name = "dbdump-secret"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "dbdump_secret" {
  metadata {
    name      = "dbdump-secret"
    namespace = var.namespace
  }

  data = {
    "database-password-readonly" = var.database_password_readonly
    "credential.json"            = var.gcloud_service_account_key
  }

  type = "Opaque"
}

provider "kubernetes" {
  version = "~> 1.8"
}
