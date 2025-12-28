resource "kubernetes_deployment" "website"{
    metadata{
        name = "website"
        namespace = kubernetes_namespace.nginx.metadata[0].name
        labels = {
            app = "website"
        }
    }

    spec {
        replicas = 2

        selector{
            match_labels = {
                app = "website" 
            }
        } 

        strategy {
            type = "RollingUpdate"
            rolling_update {
                max_surge       = "25%"
                max_unavailable = "25%"
            }
        }

        template {
            metadata{
                labels ={
                    app = "website"
                }
            }

            spec{
                automount_service_account_token = false
                enable_service_links            = false

                container { 
                    name  = "portfolio"
                    image = "asia-south1-docker.pkg.dev/high-form-479315-n2/portfolio-repo/portfolio:latest"
                    image_pull_policy = "Always"
                }
            }
        }
    }
    lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels["app.kubernetes.io/managed-by"],
      spec[0].template[0].metadata[0].annotations,
      spec[0].template[0].metadata[0].labels["app.kubernetes.io/managed-by"],
    ]
  }
}

resource "kubernetes_service" "website"{
    metadata{
        name = "website-service"
        namespace = "nginx"
        labels = {
            app = "website"
        }
    }

    spec{
        selector = { 
            app =  "website"
        }

        port {
            port = 80
            target_port = 80
            protocol = "TCP"
        }

        type = "LoadBalancer"
    }
}