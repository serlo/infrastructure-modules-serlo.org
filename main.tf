module "server" {
  source            = "./server"
  namespace         = var.namespace
  image_tags        = var.server.image_tags
  image_pull_policy = var.image_pull_policy

  php_recaptcha_key    = var.server.recaptcha.key
  php_recaptcha_secret = var.server.recaptcha.secret
  php_smtp_password    = var.server.smtp_password
  php_newsletter_key   = var.server.mailchimp_key

  database_password_default  = var.server.database.password
  database_password_readonly = var.server.database_readonly.password
  database_private_ip        = var.server.database.host

  domain = var.server.domain

  upload_secret = var.server.upload_secret

  editor_renderer_uri        = module.editor_renderer.service_uri
  legacy_editor_renderer_uri = module.legacy_editor_renderer.service_uri
  hydra_admin_uri            = var.server.hydra_admin_uri

  enable_basic_auth = var.server.enable_basic_auth
  enable_cronjobs   = var.server.enable_cronjobs
  enable_mail_mock  = var.server.enable_mail_mock

  database_username_default  = "serlo"
  database_username_readonly = "serlo_readonly"

  api                          = var.server.api
  feature_flags                = var.server.feature_flags
  autoreview_taxonomy_term_ids = var.server.autoreview_taxonomy_term_ids

  php_tracking_hotjar           = var.server.enable_tracking_hotjar
  php_tracking_google_analytics = var.server.enable_tracking_google_analytics
  php_tracking_simple_analytics = var.server.enable_tracking_simple_analytics
  php_tracking_matomo           = var.server.enable_tracking_matomo
  matomo_tracking_domain        = var.server.matomo_tracking_domain
}

module "editor_renderer" {
  source            = "./editor-renderer"
  namespace         = var.namespace
  image_tag         = var.editor_renderer.image_tag
  image_pull_policy = var.image_pull_policy
}

module "legacy_editor_renderer" {
  source            = "./legacy-editor-renderer"
  namespace         = var.namespace
  image_tag         = var.legacy_editor_renderer.image_tag
  image_pull_policy = var.image_pull_policy
}

module "varnish" {
  source = "github.com/serlo/infrastructure-modules-shared.git//varnish?ref=v3.0.3"

  namespace                 = var.namespace
  image_tag                 = var.varnish.image_tag
  image_pull_policy         = var.image_pull_policy
  host                      = module.server.service_name
  readiness_probe_http_path = "/health.php"
}
