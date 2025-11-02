locals {
  argocd_namespace = "argocd"
  app_namespace    = "movie-db"
}

# --- Namespaces ---
resource "kubernetes_namespace" "argocd" {
  metadata { name = local.argocd_namespace }
}

resource "kubernetes_namespace" "app" {
  metadata { name = local.app_namespace }
}

# --- ArgoCD Installation ---
resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.18"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [<<-YAML
    configs:
      params:
        server.insecure: true
  YAML
  ]
  depends_on = [kubernetes_namespace.argocd]
}

# --- ArgoCD Application: Movie DB ---
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
data "kubectl_path_documents" "monitoring_crds_app" {
  pattern = "${path.module}/monitoring_crds_app.yaml"
}

resource "kubectl_manifest" "monitoring_crds_app" {
  yaml_body  = data.kubectl_path_documents.monitoring_crds_app.documents[0]
  depends_on = [helm_release.argocd]
}

# --- Monitoring Application ---
data "kubectl_path_documents" "mon_app" {
  pattern = "${path.module}/monitoring_app.yaml"
}

resource "kubectl_manifest" "mon_app" {
  yaml_body  = data.kubectl_path_documents.mon_app.documents[0]
  depends_on = [helm_release.argocd, kubectl_manifest.monitoring_crds_app]
}

# --- ArgoCD Admin Secret ---
data "kubernetes_secret" "argocd_initial" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  depends_on = [helm_release.argocd]
}

output "argocd_admin_password" {
  value       = try(data.kubernetes_secret.argocd_initial.data.password, "")
  description = "Base64-encoded ArgoCD admin password"
  sensitive   = true
}
