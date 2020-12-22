variable "namespace" {
  type        = string
  description = "Namespace for this module."
}

variable "dbdump_image" {
  description = "image name of dbsetup"
  default     = "eu.gcr.io/serlo-shared/athene2-dbdump-cronjob:latest"
}

variable "image_pull_policy" {
  description = "pull policy for the container image"
  default     = "Always"
}

variable "database_username_readonly" {
  type        = string
  description = "Database username for readonly user"
  default     = "serlo_readonly"
}

variable "database_password_readonly" {
  description = "Database password for readonly user"
}

variable "database_host" {
  description = "Athene2 database host"
}

variable "gcloud_bucket_url" {
  description = "Bucket URL for anonymous database dump should be set only in gcloud environment"
  default     = "gs://anonymous-data"
}

variable "gcloud_service_account_key" {
  description = "Private key of gcloud service account to access the anonymous dtabase dump"
}

variable "gcloud_service_account_name" {
  description = "Name of the gcloud service account to access the anonymous database dump"
}