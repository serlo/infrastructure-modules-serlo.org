#####################################################################
# variables for module athene2
#####################################################################
variable "php_image" {
  description = "Docker image for athene2 php-application."
}

variable "php_definitions-file_path" {
  description = "Path to definitions.php file (by default inside secrets-folder)."
}

variable "upload_secret" {
  description = "Service account key for file uploads"
}

variable "httpd_image" {
  description = "Docker image for athene2 webserver."
}

variable "notifications-job_image" {
  description = "Docker image for notifications job."
}

variable "domain" {
  type        = string
  description = "public domain"
}

variable "database_username_default" {
  default     = "serlo"
  description = "Default username for athene2 database."
}

variable "database_password_default" {
  description = "Password for default username in athene2 database."
}

variable "database_username_readonly" {
  default     = "serlo_readonly"
  description = "Username for 'readonly user' in athene2 database."
}

variable "database_password_readonly" {
  description = "Password for 'readonly user' in athene2 database."
}

variable "database_private_ip" {
  description = "private ip address of database"
}

variable "namespace" {
  default     = "athene2"
  description = "Namespace for this module."
}

variable "app_replicas" {
  default     = 4
  description = "Number of athene2 pods"
}

variable "php_smtp_password" {
  description = "Password for smtp"
}

variable "php_tracking_switch" {
  description = "Flag whether to activate tracking or not -> usually only set to true in production"
  default     = "false"
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
  default     = "400m"
}

variable "httpd_container_limits_memory" {
  type        = string
  description = "resources limits memory for httpd container"
  default     = "500Mi"
}

variable "httpd_container_requests_cpu" {
  type        = string
  description = "resources requests cpu for httpd container"
  default     = "250m"
}

variable "httpd_container_requests_memory" {
  type        = string
  description = "resources requests memory for httpd container"
  default     = "200Mi"
}

variable "php_container_limits_cpu" {
  type        = string
  description = "resources limits cpu for php container"
  default     = "2000m"
}

variable "php_container_limits_memory" {
  type        = string
  description = "resources limits memory for php container"
  default     = "500Mi"
}

variable "php_container_requests_cpu" {
  type        = string
  description = "resources requests cpu for php container"
  default     = "250m"
}

variable "php_container_requests_memory" {
  type        = string
  description = "resources requests memory for httpd container"
  default     = "250Mi"
}

variable "image_pull_policy" {
  type        = string
  description = "image pull policy usually Always for minikube should be set to Never"
  default     = "Always"
}

variable "editor_renderer_uri" {
  type        = string
  description = "connection uri for editor renderer"
}

variable "legacy_editor_renderer_uri" {
  type        = string
  description = "connection uri for legacy editor renderer"
}

variable "enable_cronjobs" {
  type        = bool
  description = "enables athene2 cronjob (notification worker & session gc)"
  default     = false
}

variable "enable_mail_mock" {
  type        = bool
  description = "mocks emails instead of sending them out"
  default     = false
}

variable "enable_basic_auth" {
  type        = bool
  description = "enables basic auth to avoid indexing"
  default     = false
}
