locals {
  argocd_namespace = "argocd"
  app_namespace    = "movie-db"
}

# --- Namespaces ---
resource "kubernetes_namespace" "argocd" {
  metadata { name = local.argocd_namespace }
}

# Install ArgoCD via Helm
resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.18" # pin a recent stable version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Minimal values, defaults are fine for local
  values = [<<-YAML
    configs:
      params:
        server.insecure: true
  YAML
  ]
  depends_on = [kubernetes_namespace.argocd]
}

# Create app namespace (ArgoCD could do it too)
resource "kubernetes_namespace" "app" {
  metadata { name = local.app_namespace }
}

# Render the Application with envsubst-like replacement, then apply via kubectl provider
data "kubectl_path_documents" "app" {
  pattern = "${path.module}/argocd_app.yaml"
  vars = {
    APP_REPO_URL = var.app_repo_url
    APP_PATH     = var.app_path
    APP_REVISION = var.app_revision
  }
}

resource "kubectl_manifest" "app" {
  yaml_body  = data.kubectl_path_documents.app.documents[0]
  depends_on = [helm_release.argocd, kubernetes_namespace.app]
}

# --- Monitoring CRDs Application ---
# data "kubectl_path_documents" "monitoring_crds_app" {
#   pattern = "${path.module}/monitoring_crds_app.yaml"
# }
#
# resource "kubectl_manifest" "monitoring_crds_app" {
#   yaml_body  = data.kubectl_path_documents.monitoring_crds_app.documents[0]
#   depends_on = [helm_release.argocd]
# }

# --- Monitoring Application ---
data "kubectl_path_documents" "mon_app" {
  pattern = "${path.module}/monitoring_app.yaml"
}

resource "kubectl_manifest" "mon_app" {
  yaml_body  = data.kubectl_path_documents.mon_app.documents[0]
  depends_on = [helm_release.argocd]
  # depends_on = [helm_release.argocd, kubectl_manifest.monitoring_crds_app]
}

output "argocd_admin_password" {
  value       = try(data.kubernetes_secret.argocd_initial.data.password, "")
  description = "ArgoCD admin password"
  sensitive   = true
}

# Pull initial admin secret (best-effort)
data "kubernetes_secret" "argocd_initial" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  depends_on = [helm_release.argocd]
}
