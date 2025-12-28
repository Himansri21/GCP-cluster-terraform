output "cluster_name"{
    description = "GKE cluster name"
    value = google_container_cluster.primary.name
}

output "cluster_endpoint"{
    description = "GKE cluster endpoint"
    value = google_container_cluster.primary.endpoint
    sensitive = true
}

output "cluster_location" {
    description = "GKE cluster location"
    value = google_container_cluster.primary.location
}

output "nginx_load_balancer_ip"{
    description = "NGINX load balancer IP - visit this in your browser"
    value = kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip
}

output "kubectl_connect_command" {
    description = "run this command to configure kubectl"
    value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${var.zone} --project ${var.project_id}"
}

output "website_load_balancer_ip" {
  description = "Website LoadBalancer IP"
  value       = kubernetes_service.website.status[0].load_balancer[0].ingress[0].ip
}