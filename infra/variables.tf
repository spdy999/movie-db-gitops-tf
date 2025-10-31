variable "kubeconfig" {
  description = "Path to kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "app_repo_url" {
  description = "Git repo URL ArgoCD will sync from (this repo path). For local demo, keep as placeholder and ArgoCD will still use in-cluster repo-server (you can push this repo and update)"
  type        = string
  default     = "https://github.com/spdy999/movie-db-gitops-tf"
}

variable "app_path" {
  description = "Path inside repo for the Helm chart"
  type        = string
  default     = "apps/movie-db"
}

variable "app_revision" {
  description = "Git revision (branch, tag, or commit)"
  type        = string
  default     = "HEAD"
}
