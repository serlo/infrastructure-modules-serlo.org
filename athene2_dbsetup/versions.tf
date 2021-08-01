terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.0"
    }
  }
}
