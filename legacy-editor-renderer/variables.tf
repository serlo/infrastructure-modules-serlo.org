#####################################################################
# variables for module legacy-editor-renderer
#####################################################################
variable "image_tag" {
  description = "Docker image for legacy-editor-renderer."
  type        = string
}

variable "namespace" {
  default     = "athene2"
  description = "Namespace for all resources inside module legacy-editor-renderer."
}

variable "image_pull_policy" {
  type        = string
  description = "image pull policy usually Always for minikube should be set to Never"
  default     = "Always"
}

variable "container_limits_cpu" {
  type        = string
  description = "resources limits cpu for container"
  default     = "500m"
}

variable "container_limits_memory" {
  type        = string
  description = "resources limits memory for container"
  default     = "200Mi"
}

variable "container_requests_cpu" {
  type        = string
  description = "resources requests cpu for container"
  default     = "250m"
}

variable "container_requests_memory" {
  type        = string
  description = "resources requests memory for container"
  default     = "100Mi"
}

variable "app_replicas" {
  type        = number
  description = "number of replicas in the cluster"
  default     = 1
}
