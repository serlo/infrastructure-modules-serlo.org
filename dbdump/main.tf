locals {
  name = "dbdump"
}

resource "kubernetes_cron_job" "dbdump" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    concurrency_policy = "Forbid"
    schedule           = var.schedule
    job_template {
      metadata {}
      spec {
        backoff_limit = 2
        template {
          metadata {}
          spec {
            container {
              name  = "dbdump"
              image = var.image
              args  = ["/bin/sh", "/tmp/run.sh"]

              volume_mount {
                mount_path = "/tmp/run.sh"
                sub_path   = "run.sh"
                name       = "run-sh-volume"
                read_only  = true
              }
            }

            volume {
              name = "run-sh-volume"

              secret {
                secret_name = kubernetes_secret.dbdump.metadata.0.name

                items {
                  key  = "run.sh"
                  path = "run.sh"
                  mode = "0444"
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "dbdump" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  data = {
    "run.sh" = data.template_file.run_sh_template.rendered
  }
}

data "template_file" run_sh_template {
  template = file("${path.module}/run.sh.tpl")

  vars = {
    database_host     = var.database.host
    database_port     = var.database.port
    database_username = var.database.username
    database_password = var.database.password
    database_name     = var.database.name

    bucket_url                 = var.bucket.url
    bucket_service_account_key = var.bucket.service_account_key
  }
}

provider "kubernetes" {
  version = "~> 1.8"
}

provider "template" {
  version = "~> 2.1"
}
# resource "kubernetes_deployment" "dbdump-cronjob" {
#   metadata {
#     name      = "dbdump-cronjob"
#     namespace = var.namespace

#     labels = {
#       app = "dbdump"
#     }
#   }

#   spec {
#     replicas = "1"

#     selector {
#       match_labels = {
#         app = "dbdump"
#       }
#     }

#     strategy {
#       type = "Recreate"
#     }

#     template {
#       metadata {
#         labels = {
#           app  = "dbdump"
#           name = "dbdump"
#         }
#       }

#       spec {
#         container {
#           image             = var.dbdump_image
#           name              = "dbdump-container"
#           image_pull_policy = var.image_pull_policy

#           env {
#             name  = "GCLOUD_BUCKET_URL"
#             value = var.gcloud_bucket_url
#           }
#           env {
#             name  = "GCLOUD_SERVICE_ACCOUNT_NAME"
#             value = var.gcloud_service_account_name
#           }
#           env {
#             name = "GCLOUD_SERVICE_ACCOUNT_KEY"
#             value_from {
#               secret_key_ref {
#                 key  = "credential.json"
#                 name = kubernetes_secret.dbdump_secret.metadata[0].name
#               }
#             }
#           }
#           env {
#             name  = "ATHENE2_DATABASE_HOST"
#             value = var.database_host
#           }
#           env {
#             name  = "ATHENE2_DATABASE_PORT"
#             value = "3306"
#           }
#           env {
#             name  = "ATHENE2_DATABASE_USER"
#             value = var.database_username_readonly
#           }
#           env {
#             name = "ATHENE2_DATABASE_PASSWORD"
#             value_from {
#               secret_key_ref {
#                 key  = "database-password-readonly"
#                 name = "dbdump-secret"
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_secret" "dbdump_secret" {
#   metadata {
#     name      = "dbdump-secret"
#     namespace = var.namespace
#   }

#   data = {
#     "database-password-readonly" = var.database_password_readonly
#     "credential.json"            = var.gcloud_service_account_key
#   }

#   type = "Opaque"
# }

# provider "kubernetes" {
#   version = "~> 1.8"
# }
