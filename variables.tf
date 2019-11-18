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
    images = object({
      httpd             = string
      php               = string
      notifications_job = string
    })

    domain                = string
    definitions_file_path = string

    recaptcha = object({
      key    = string
      secret = string
    })

    smtp_password = string
    mailchimp_key = string

    enable_tracking = bool

    database = object({
      host     = string
      username = string
      password = string
    })

    database_readonly = object({
      username = string
      password = string
    })

    upload_secret = string
    feature_flags = string
    hydra_uri     = string
  })
}

variable "editor_renderer" {
  description = "Configuration for editor renderer"
  type = object({
    app_replicas = number
    image        = string
  })
}

variable "legacy_editor_renderer" {
  description = "Configuration for legacy editor renderer"
  type = object({
    app_replicas = number
    image        = string
  })
}

variable "varnish" {
  description = "Configuration for varnish"
  type = object({
    app_replicas = number
    image        = string
  })
}
