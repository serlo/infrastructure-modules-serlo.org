locals {
  name = "server"
  curl = "curl${var.enable_basic_auth ? " --user serloteam:serloteam" : ""} --data \"secret=${random_string.cronjob_secret.result}\" --verbose"
}

resource "kubernetes_service" "server" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = local.name
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "server" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = local.name
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        container {
          image             = "eu.gcr.io/serlo-shared/serlo-org-httpd:${var.image_tags.httpd}"
          name              = "httpd"
          image_pull_policy = var.image_pull_policy

          port {
            container_port = 80
          }

          env {
            name  = "PHP_HOST"
            value = "localhost"
          }

          env {
            name  = "HTTP_OVERRIDE_CONF_CHECKSUM"
            value = sha256(data.template_file.override_httpd_conf_template.rendered)
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

        container {
          image             = "eu.gcr.io/serlo-shared/serlo-org-php:${var.image_tags.php}"
          name              = "php"
          image_pull_policy = var.image_pull_policy

          env {
            name  = "DEFINITIONS_PHP_CHECKSUM"
            value = sha256(data.template_file.definitions_php_template.rendered)
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
              command = ["/bin/bash", "-c", "curl http://localhost/health.php -f && curl ${var.legacy_editor_renderer_uri} && curl ${var.editor_renderer_uri} && curl ${var.frontend_uri}"]
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
            secret_name = kubernetes_secret.server.metadata.0.name

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
            name = local.name

            items {
              key  = "httpd-override.conf"
              path = "httpd-override.conf"
              mode = "0444"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_cron_job" "notifications" {
  count = var.enable_cronjobs ? 1 : 0

  metadata {
    name      = "notifications"
    namespace = var.namespace

    labels = {
      app = local.name
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
            container {
              name  = "worker"
              image = "eu.gcr.io/serlo-shared/serlo-org-notifications-job:${var.image_tags.notifications_job}"

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

resource "kubernetes_cron_job" "session_gc" {
  count = var.enable_cronjobs ? 1 : 0

  metadata {
    name      = "session-gc"
    namespace = var.namespace

    labels = {
      app = local.name
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

resource "kubernetes_secret" "server" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  data = {
    "definitions-file" = data.template_file.definitions_php_template.rendered
  }
}

resource "kubernetes_config_map" "server" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  data = {
    "httpd-override.conf" = data.template_file.override_httpd_conf_template.rendered
  }
}

resource "random_string" "cronjob_secret" {
  length  = 32
  special = false
}

data "template_file" definitions_php_template {
  template = file("${path.module}/definitions.php.tpl")

  vars = {
    php_recaptcha_key          = var.php_recaptcha_key
    php_recaptcha_secret       = var.php_recaptcha_secret
    php_smtp_password          = var.php_smtp_password
    php_newsletter_key         = var.php_newsletter_key
    php_tracking_switch        = var.php_tracking_switch
    php_db_host                = var.database_private_ip
    editor_renderer_uri        = var.editor_renderer_uri
    legacy_editor_renderer_uri = var.legacy_editor_renderer_uri
    frontend_uri               = var.frontend_uri
    hydra_admin_uri            = var.hydra_admin_uri
    cronjob_secret             = random_string.cronjob_secret.result
    enable_mail_mock           = var.enable_mail_mock
    upload_secret              = var.upload_secret
    database_username          = var.database_username_default
    database_password          = var.database_password_default
    feature_flags              = var.feature_flags
    redis_hosts                = var.redis_hosts
    kafka_host                 = var.kafka_host
  }
}

data "template_file" override_httpd_conf_template {
  template = file("${path.module}/override.httpd.conf.tpl")
}
