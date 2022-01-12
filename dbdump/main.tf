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
            node_selector = {
              "cloud.google.com/gke-nodepool" = var.node_pool
            }

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

data "template_file" "run_sh_template" {
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
