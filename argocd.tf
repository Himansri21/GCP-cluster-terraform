# argocd.tf

# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  count = var.enable_argocd ? 1 : 0

  metadata {
    name = "argocd"
  }

  depends_on = [google_container_cluster.primary]
}

# Deploy ArgoCD using Helm
resource "helm_release" "argocd" {
  count = var.enable_argocd ? 1 : 0

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.7.11"
  namespace  = kubernetes_namespace.argocd[0].metadata[0].name

  values = [
    <<-EOT
    server:
      service:
        type: LoadBalancer
      extraArgs:
        - --insecure

    configs:
      params:
        server.insecure: true
      
      repositories:
        - url: https://github.com/Himansri21/GCP-cluster-terraform
          type: git
        - url: ${var.website_repo_url}
          type: git
    
    controller:
      resources:
        limits:
          cpu: 1000m
          memory: 1Gi
        requests:
          cpu: 500m
          memory: 512Mi
    
    server:
      resources:
        limits:
          cpu: 500m
          memory: 512Mi
        requests:
          cpu: 250m
          memory: 256Mi
    
    repoServer:
      resources:
        limits:
          cpu: 500m
          memory: 512Mi
        requests:
          cpu: 250m
          memory: 256Mi
    EOT
  ]

  wait    = true
  timeout = 600

  depends_on = [
    google_container_cluster.primary,
    kubernetes_namespace.argocd
  ]
}

# Deploy Root App of Apps
resource "kubectl_manifest" "root_app_of_apps" {
  count = var.enable_argocd ? 1 : 0

  yaml_body = file("${path.module}/../argocd-apps/root-app.yaml")

  depends_on = [helm_release.argocd]
}

# Get ArgoCD admin password
data "kubernetes_secret" "argocd_admin_password" {
  count = var.enable_argocd ? 1 : 0

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd[0].metadata[0].name
  }

  depends_on = [helm_release.argocd]
}