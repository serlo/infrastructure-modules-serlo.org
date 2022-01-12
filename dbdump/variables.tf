variable "image" {
  description = "Image to use"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "node_pool" {
  type        = string
  description = "Node pool to use"
}

variable "schedule" {
  description = "Crontab-like schedule for the cron job"
  type        = string
}

variable "database" {
  description = "Database connection configuration"
  type = object({
    host     = string
    port     = string
    username = string
    password = string
    name     = string
  })
}

variable "bucket" {
  description = "Bucket to save the dump to"
  type = object({
    url                 = string
    service_account_key = string
  })
}
