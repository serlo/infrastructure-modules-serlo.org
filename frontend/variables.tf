#####################################################################
# variables for module legacy-editor-renderer
#####################################################################
variable "image_tag" {
  description = "Docker image tag for frontend."
  type        = string
}

variable "namespace" {
  description = "Namespace for all resources inside module frontend."
  type        = string
}

variable "image_pull_policy" {
  description = "image pull policy usually Always for minikube should be set to Never"
  type        = string
}

variable "container_limits_cpu" {
  description = "resources limits cpu for container"
  type        = string
  default     = "500m"
}

variable "container_limits_memory" {
  description = "resources limits memory for container"
  type        = string
  default     = "200Mi"
}

variable "container_requests_cpu" {
  description = "resources requests cpu for container"
  type        = string
  default     = "250m"
}

variable "container_requests_memory" {
  description = "resources requests memory for container"
  type        = string
  default     = "100Mi"
}

variable "app_replicas" {
  description = "number of replicas in the cluster"
  type        = number
  default     = 1
}
