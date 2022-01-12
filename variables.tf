variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "image_pull_policy" {
  description = "Image pull policy"
  type        = string
}

variable "node_pool" {
  type        = string
  description = "Node pool to use"
}

variable "server" {
  description = "Configuration for server"
  type = object({
    image_tags = object({
      httpd             = string
      php               = string
      migrate           = string
      notifications_job = string
    })

    domain = string

    recaptcha = object({
      key    = string
      secret = string
    })

    smtp_password = string
    mailchimp_key = string

    enable_basic_auth = bool
    enable_cronjobs   = bool
    enable_mail_mock  = bool

    database = object({
      host     = string
      username = string
      password = string
    })

    database_readonly = object({
      username = string
      password = string
    })

    upload_secret                = string
    feature_flags                = string
    hydra_admin_uri              = string
    autoreview_taxonomy_term_ids = string

    api = object({
      host   = string
      secret = string
    })

    enable_tracking_hotjar           = bool
    enable_tracking_google_analytics = bool
    enable_tracking_simple_analytics = bool
    enable_tracking_matomo           = bool
    matomo_tracking_domain           = string
  })
}

variable "editor_renderer" {
  description = "Configuration for editor renderer"
  type = object({
    image_tag = string
  })
}

variable "legacy_editor_renderer" {
  description = "Configuration for legacy editor renderer"
  type = object({
    image_tag = string
  })
}

variable "varnish" {
  description = "Configuration for varnish"
  type = object({
    image_tag = string
  })
}
