terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

# Kubernetes provider — used by both Helm and Kubectl
provider "kubernetes" {
  config_path = var.kubeconfig
}

# Helm provider — use nested kubernetes block (supported in v2.11.x)
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}

# Kubectl provider for ArgoCD manifests
provider "kubectl" {
  config_path      = var.kubeconfig
  load_config_file = true
}
