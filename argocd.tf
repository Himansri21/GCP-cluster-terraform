# argocd.tf

resource "kubernetes_namespace" "argocd" {
  count = var.enable_argocd ? 1 : 0

  metadata {
    name = "argocd"
  }

  depends_on = [google_container_cluster.primary]
}

resource "helm_release" "argocd" {
  count = var.enable_argocd ? 1 : 0

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.7.11"
  namespace  = kubernetes_namespace.argocd[0].metadata[0].name
  skip_crds = false

  values = [
    <<-EOT
    global:
      # Minimal resources for small cluster
      resources:
        limits:
          cpu: 100m
          memory: 128Mi
        requests:
          cpu: 50m
          memory: 64Mi

    server:
      service:
        type: LoadBalancer
      extraArgs:
        - --insecure
      replicas: 1
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi

    controller:
      replicas: 1
      resources:
        limits:
          cpu: 512m
          memory: 1024Mi
        #requests:
         # cpu: 100m
         # memory: 256Mi

    repoServer:
      replicas: 1
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi

    redis:
      resources:
        limits:
          cpu: 100m
          memory: 128Mi
        requests:
          cpu: 50m
          memory: 64Mi

    configs:
      params:
        server.insecure: true
      
      repositories:
        - url: https://github.com/Himansri21/GCP-cluster-terraform
          type: git
        - url: ${var.website_repo_url}
          type: git

    # Disable heavy components
    dex:
      enabled: false

    notifications:
      enabled: false

    applicationSet:
      enabled: false
    EOT
  ]

  wait    = false  # Don't wait - let it deploy in background
  timeout = 900

  depends_on = [
    google_container_cluster.primary,
    kubernetes_namespace.argocd
  ]
}

#resource "kubectl_manifest" "root_app_of_apps" {
 # count = var.enable_argocd ? 1 : 0

  #yaml_body = file("${path.module}/../Argocd-apps/root-app.yaml")

  #depends_on = [helm_release.argocd]
#}

data "kubernetes_secret" "argocd_admin_password" {
  count = var.enable_argocd ? 1 : 0

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd[0].metadata[0].name
  }

  depends_on = [helm_release.argocd]
}