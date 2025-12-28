# outputs.tf

# ===== EXISTING OUTPUTS =====
output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_location" {
  description = "GKE cluster location"
  value       = google_container_cluster.primary.location
}

output "nginx_load_balancer_ip" {
  description = "NGINX load balancer IP - visit this in your browser"
  value       = kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip
}

output "kubectl_connect_command" {
  description = "run this command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${var.zone} --project ${var.project_id}"
}

output "website_load_balancer_ip" {
  description = "Website LoadBalancer IP"
  value       = kubernetes_service.website.status[0].load_balancer[0].ingress[0].ip
}

# ===== NEW: ArgoCD OUTPUTS =====
output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = var.enable_argocd ? try(nonsensitive(data.kubernetes_secret.argocd_admin_password[0].data["password"]), "Waiting for ArgoCD to deploy...") : "ArgoCD not enabled"
  sensitive   = false
}

output "argocd_server_command" {
  description = "Command to get ArgoCD LoadBalancer IP"
  value       = var.enable_argocd ? "kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}'" : "ArgoCD not enabled"
}

output "argocd_port_forward_command" {
  description = "Command to access ArgoCD via port-forward"
  value       = var.enable_argocd ? "kubectl port-forward svc/argocd-server -n argocd 8080:80" : "ArgoCD not enabled"
}

output "argocd_access_instructions" {
  description = "How to access ArgoCD"
  value       = var.enable_argocd ? join("\n", [
    "",
    "========================================",
    "ArgoCD Access Instructions",
    "========================================",
    "",
    "STEP 1: Get admin password",
    "terraform output argocd_admin_password",
    "",
    "STEP 2: Access ArgoCD (choose one method)",
    "",
    "Method A - Port Forward (immediate access):",
    "kubectl port-forward svc/argocd-server -n argocd 8080:80",
    "Then visit: http://localhost:8080",
    "",
    "Method B - LoadBalancer IP (wait 1-2 min for IP):",
    "kubectl get svc argocd-server -n argocd",
    "Then visit: http://<EXTERNAL-IP>",
    "",
    "Login:",
    "Username: admin",
    "Password: (from step 1)",
    "",
    "========================================"
  ]) : "ArgoCD not enabled"
}