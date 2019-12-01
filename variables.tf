variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "image_pull_policy" {
  description = "Image pull policy"
  type        = string
}

variable "server" {
  description = "Configuration for server"
  type = object({
    app_replicas = number
    image_tags = object({
      httpd             = string
      php               = string
      notifications_job = string
    })
    resources = object({
      httpd = object({
        limits = object({
          cpu    = string
          memory = string
        })
        requests = object({
          cpu    = string
          memory = string
        })
      })
      php = object({
        limits = object({
          cpu    = string
          memory = string
        })
        requests = object({
          cpu    = string
          memory = string
        })
      })
    })

    domain                = string
    definitions_file_path = string

    recaptcha = object({
      key    = string
      secret = string
    })

    smtp_password = string
    mailchimp_key = string

    enable_tracking   = bool
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

    upload_secret   = string
    feature_flags   = string
    hydra_admin_uri = string
  })
}

variable "editor_renderer" {
  description = "Configuration for editor renderer"
  type = object({
    app_replicas = number
    image_tag    = string
  })
}

variable "legacy_editor_renderer" {
  description = "Configuration for legacy editor renderer"
  type = object({
    app_replicas = number
    image_tag    = string
  })
}

variable "frontend" {
  description = "Configuration for frontend"
  type = object({
    app_replicas = number
    image_tag    = string
  })
}

variable "varnish" {
  description = "Configuration for varnish"
  type = object({
    app_replicas = number
    image        = string
    memory       = string
  })
}
