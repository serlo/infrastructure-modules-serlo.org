variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "image_pull_policy" {
  description = "Image pull policy"
  type        = string
}

variable "image_tags" {
  description = "Docker image tags to use"
  type = object({
    httpd             = string
    php               = string
    migrate           = string
    notifications_job = string
  })
}

variable "domain" {
  description = "Public Domain of the service"
  type        = string
}

variable "feature_flags" {
  description = "Configures feature flags"
  type        = string
}

variable "redis_hosts" {
  description = "Redis hosts to use"
  type        = string
}

variable "kafka_host" {
  description = "Kafka host to use"
  type        = string
}

### REVIEW

variable "php_definitions-file_path" {
  description = "Path to definitions.php file (by default inside secrets-folder)."
}

variable "upload_secret" {
  description = "Service account key for file uploads"
}



variable "database_username_default" {
  description = "Default username for athene2 database."
}

variable "database_password_default" {
  description = "Password for default username in athene2 database."
}

variable "database_username_readonly" {
  description = "Username for 'readonly user' in athene2 database."
}

variable "database_password_readonly" {
  description = "Password for 'readonly user' in athene2 database."
}

variable "database_private_ip" {
  description = "private ip address of database"
}

variable "app_replicas" {
  description = "Number of athene2 pods"
}

variable "php_smtp_password" {
  description = "Password for smtp"
}

variable "php_tracking_switch" {
  description = "Flag whether to activate tracking or not -> usually only set to true in production"
}

variable "php_recaptcha_key" {
  description = "Key for recaptcha"
}

variable "php_recaptcha_secret" {
  description = "Secret for recaptcha"
}

variable "php_newsletter_key" {
  description = "Key for newsletter"
}

variable "httpd_container_limits_cpu" {
  type        = string
  description = "resources limits cpu for httpd container"
}

variable "httpd_container_limits_memory" {
  type        = string
  description = "resources limits memory for httpd container"
}

variable "httpd_container_requests_cpu" {
  type        = string
  description = "resources requests cpu for httpd container"
}

variable "httpd_container_requests_memory" {
  type        = string
  description = "resources requests memory for httpd container"
}

variable "php_container_limits_cpu" {
  type        = string
  description = "resources limits cpu for php container"
}

variable "php_container_limits_memory" {
  type        = string
  description = "resources limits memory for php container"
}

variable "php_container_requests_cpu" {
  type        = string
  description = "resources requests cpu for php container"
}

variable "php_container_requests_memory" {
  type        = string
  description = "resources requests memory for httpd container"
}

variable "editor_renderer_uri" {
  type        = string
  description = "connection uri for editor renderer"
}

variable "frontend_uri" {
  type        = string
  description = "connection uri for frontend"
}

variable "legacy_editor_renderer_uri" {
  type        = string
  description = "connection uri for legacy editor renderer"
}

variable "hydra_admin_uri" {
  type        = string
  description = "connection uri for hydra admin"
}

variable "enable_cronjobs" {
  type        = bool
  description = "enables athene2 cronjob (notification worker & session gc)"
}

variable "enable_mail_mock" {
  type        = bool
  description = "mocks emails instead of sending them out"
}

variable "enable_basic_auth" {
  type        = bool
  description = "enables basic auth to avoid indexing"
}
