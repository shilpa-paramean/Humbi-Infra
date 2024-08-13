# Kubernetes custom providers:
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73.0"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.9"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 1.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.9.4"
    }
  }
}