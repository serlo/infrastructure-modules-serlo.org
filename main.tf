module "server" {
  source = "./server"
  images = var.server.images

  namespace         = var.namespace
  image_pull_policy = var.image_pull_policy

  php_definitions-file_path = var.server.definitions_file_path

  php_recaptcha_key    = var.server.recaptcha.key
  php_recaptcha_secret = var.server.recaptcha.secret
  php_smtp_password    = var.server.smtp_password
  php_newsletter_key   = var.server.mailchimp_key
  php_tracking_switch  = var.server.enable_tracking

  database_password_default  = var.server.database.password
  database_password_readonly = var.server.database_readonly.password
  database_private_ip        = var.server.database.host

  app_replicas = var.server.app_replicas

  httpd_container_limits_cpu      = var.server.resources.httpd.limits.cpu
  httpd_container_limits_memory   = var.server.resources.httpd.limits.memory
  httpd_container_requests_cpu    = var.server.resources.httpd.requests.cpu
  httpd_container_requests_memory = var.server.resources.httpd.requests.memory

  php_container_limits_cpu      = var.server.resources.php.limits.cpu
  php_container_limits_memory   = var.server.resources.php.limits.memory
  php_container_requests_cpu    = var.server.resources.php.requests.cpu
  php_container_requests_memory = var.server.resources.php.requests.memory

  domain = var.server.domain

  upload_secret = var.server.upload_secret

  legacy_editor_renderer_uri = module.legacy_editor_renderer.service_uri
  editor_renderer_uri        = module.editor_renderer.service_uri
  hydra_admin_uri            = var.server.hydra_admin_uri

  enable_basic_auth = var.server.enable_basic_auth
  enable_cronjobs   = var.server.enable_cronjobs
  enable_mail_mock  = var.server.enable_mail_mock

  database_username_default  = "serlo"
  database_username_readonly = "serlo_readonly"

  feature_flags = var.server.feature_flags

  providers = {
    kubernetes = "kubernetes"
    random     = "random"
    template   = "template"
  }
}

module "editor_renderer" {
  source       = "./editor-renderer"
  image        = var.editor_renderer.image
  namespace    = var.namespace
  app_replicas = var.editor_renderer.app_replicas

  providers = {
    kubernetes = "kubernetes"
  }
}

module "legacy_editor_renderer" {
  source       = "./legacy-editor-renderer"
  image        = var.legacy_editor_renderer.image
  namespace    = var.namespace
  app_replicas = var.legacy_editor_renderer.app_replicas

  providers = {
    kubernetes = "kubernetes"
  }
}

module "varnish" {
  source         = "github.com/serlo/infrastructure-modules-shared.git//varnish?ref=02e58fdcdf0c83d9f99d7e6ca5911768149755a5"
  namespace      = var.namespace
  app_replicas   = var.varnish.app_replicas
  backend_ip     = module.server.service_name
  image          = var.varnish.image
  varnish_memory = var.varnish.memory

  resources_limits_cpu      = "50m"
  resources_limits_memory   = "100Mi"
  resources_requests_cpu    = "50m"
  resources_requests_memory = "100Mi"

  providers = {
    kubernetes = "kubernetes"
    template   = "template"
  }
}

provider "kubernetes" {
  version = "~> 1.8"
}

provider "random" {
  version = "~> 2.2"
}

provider "template" {
  version = "~> 2.1"
}
