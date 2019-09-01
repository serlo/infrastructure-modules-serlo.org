locals {
  curl = "curl${var.enable_basic_auth ? " --user serloteam:serloteam" : ""} --data \"secret=${random_string.cronjob_secret.result}\" --verbose"
}

resource "kubernetes_secret" "athene2_secret" {
  metadata {
    name      = "athene2-secret"
    namespace = var.namespace
  }

  data = {
    "definitions-file" = data.template_file.definitions_php_template.rendered
  }
}

resource "kubernetes_service" "athene2_service" {
  metadata {
    name      = "athene2-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app" = kubernetes_deployment.athene2_deployment.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "athene2_deployment" {
  metadata {
    name      = "athene2-app"
    namespace = var.namespace

    labels = {
      "app" = "athene2"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        "app" = "athene2"
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          "app" = "athene2"
        }
      }

      spec {
        dns_policy = "None"
        dns_config {
          nameservers = ["8.8.8.8"]
          option {
            name  = "ndots"
            value = 1
          }
        }

        #Webserver container
        container {
          image             = var.httpd_image
          name              = "athene2-httpd-container"
          image_pull_policy = var.image_pull_policy

          port {
            container_port = 80
          }

          env {
            name  = "PHP_HOST"
            value = "localhost"
          }

          resources {
            limits {
              cpu    = var.httpd_container_limits_cpu
              memory = var.httpd_container_limits_memory
            }

            requests {
              cpu    = var.httpd_container_requests_cpu
              memory = var.httpd_container_requests_memory
            }
          }

          volume_mount {
            mount_path = "/usr/local/apache2/conf/httpd-override.conf"
            sub_path   = "httpd-override.conf"
            name       = "httpd-override-conf-volume"
            read_only  = true
          }
        }

        #PHP container
        container {
          image             = var.php_image
          name              = "athene2-php-container"
          image_pull_policy = var.image_pull_policy

          env {
            name  = "DATABASE_USERNAME"
            value = var.database_username_default
          }

          env {
            name  = "DATABASE_PASSWORD"
            value = var.database_password_default
          }

          lifecycle {
            post_start {
              exec {
                command = ["php", "src/public/index.php", "pagespeed", "build"]
              }
            }
          }

          liveness_probe {
            exec {
              command = ["/bin/bash", "-c", "curl http://localhost/health.php -f"]

            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }

          readiness_probe {
            exec {
              command = ["/bin/bash", "-c", "curl --resolve 'de.localhost:80:127.0.0.1' http://de.localhost/mathe -f"]

            }
            initial_delay_seconds = 5
            period_seconds        = 120
            failure_threshold     = 3
            success_threshold     = 1
            timeout_seconds       = 20
          }

          volume_mount {
            mount_path = "/usr/local/apache2/htdocs/src/config/definitions.local.php"
            sub_path   = "definitions.local.php"
            name       = "definitions-volume"
            read_only  = true
          }

          resources {
            limits {
              cpu    = var.php_container_limits_cpu
              memory = var.php_container_limits_memory
            }

            requests {
              cpu    = var.php_container_requests_cpu
              memory = var.php_container_requests_memory
            }
          }
        }

        volume {
          name = "definitions-volume"

          secret {
            secret_name = kubernetes_secret.athene2_secret.metadata.0.name

            items {
              key  = "definitions-file"
              path = "definitions.local.php"
              mode = "0444"
            }
          }
        }
        volume {
          name = "httpd-override-conf-volume"

          config_map {
            name = "athene2-conf"

            items {
              key  = "httpd-override.conf"
              path = "httpd-override.conf"
              mode = "0444"
            }
          }
        }

        volume {
          name = "www-conf-volume"

          config_map {
            name = "athene2-conf"

            items {
              key  = "www.conf"
              path = "www.conf"
              mode = "0444"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "athene2_conf" {
  metadata {
    name      = "athene2-conf"
    namespace = var.namespace

    labels = {
      "app" = "athene2"
    }
  }

  data = {
    "httpd-override.conf" = data.template_file.override_httpd_conf_template.rendered
    "www.conf"            = file("${path.module}/www.conf")
  }
}

resource "kubernetes_cron_job" "notification_worker_cronjob" {
  count = var.enable_cronjobs ? 1 : 0

  metadata {
    name      = "notification-worker-cronjob"
    namespace = var.namespace

    labels = {
      "app" = "athene2"
    }
  }

  spec {
    concurrency_policy = "Forbid"
    schedule           = "0 0 * * *"
    job_template {
      metadata {}
      spec {
        backoff_limit = 2
        template {
          metadata {}
          spec {
            dns_policy = "None"
            dns_config {
              nameservers = ["8.8.8.8"]
              option {
                name  = "ndots"
                value = 1
              }
            }

            container {
              name  = "worker"
              image = var.notifications-job_image

              env {
                name  = "SERVER_HOST"
                value = "https://de.${var.domain}"
              }
              env {
                name  = "DB_HOST"
                value = var.database_private_ip
              }
              env {
                name  = "DB_USER"
                value = var.database_username_readonly
              }
              env {
                name  = "DB_PASSWORD"
                value = var.database_password_readonly
              }
              env {
                name  = "DB_DATABASE"
                value = "serlo"
              }
              env {
                name  = "JOB_SECRET"
                value = random_string.cronjob_secret.result
              }
              env {
                name  = "BASIC_AUTH_USERNAME"
                value = var.enable_basic_auth ? "serloteam" : ""
              }
              env {
                name  = "BASIC_AUTH_PASSWORD"
                value = var.enable_basic_auth ? "serloteam" : ""
              }
            }
            restart_policy = "Never"
          }
        }
      }
    }
  }
}

resource "kubernetes_cron_job" "session_gc_cronjob" {
  count = var.enable_cronjobs ? 1 : 0

  metadata {
    name      = "session-gc-cronjob"
    namespace = var.namespace

    labels = {
      "app" = "athene2"
    }
  }

  spec {
    concurrency_policy = "Forbid"
    schedule           = "0 0 * * *"
    job_template {
      metadata {}
      spec {
        backoff_limit = 2
        template {
          metadata {}
          spec {
            dns_policy = "None"
            dns_config {
              nameservers = ["8.8.8.8"]
              option {
                name  = "ndots"
                value = 1
              }
            }

            container {
              name    = "worker"
              image   = "buildpack-deps:curl"
              command = ["/bin/sh", "-c", "${local.curl} https://de.${var.domain}/session/gc --verbose"]
            }
            restart_policy = "Never"
          }
        }
      }
    }
  }
}

resource "random_string" "cronjob_secret" {
  length  = 32
  special = false
}

data "template_file" definitions_php_template {
  template = "${file("${path.module}/definitions.php.tpl")}"

  vars = {
    php_recaptcha_key          = var.php_recaptcha_key
    php_recaptcha_secret       = var.php_recaptcha_secret
    php_smtp_password          = var.php_smtp_password
    php_newsletter_key         = var.php_newsletter_key
    php_tracking_switch        = var.php_tracking_switch
    php_db_host                = var.database_private_ip
    legacy_editor_renderer_uri = var.legacy_editor_renderer_uri
    editor_renderer_uri        = var.editor_renderer_uri
    cronjob_secret             = random_string.cronjob_secret.result
    enable_mail_mock           = var.enable_mail_mock
    upload_secret              = var.upload_secret
  }
}

data "template_file" override_httpd_conf_template {
  template = "${file("${path.module}/override.httpd.conf.tpl")}"

  vars = {
  }
}
