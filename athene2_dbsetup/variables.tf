variable "namespace" {
  type        = string
  description = "Namespace for this module."
}

variable "dbsetup_image" {
  description = "image name of dbsetup"
  default     = "eu.gcr.io/serlo-shared/athene2-dbsetup-cronjob:1.3.0"
}

variable "image_pull_policy" {
  description = "pull policy for the container image"
  default     = "Always"
}

variable "database_username_default" {
  type        = string
  default     = "serlo"
  description = "Database username for default user that has also write privilege"
}

variable "database_password_default" {
  description = "Database password for default user that has also write privilege"
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

variable "feature_minikube" {
  type        = bool
  description = "Feature minikube by default it is false"
  default     = false
}
