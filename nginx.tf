resource "kubernetes_namespace" "nginx"{
    metadata {
        name = "nginx"
    }

    depends_on = [google_container_node_pool.primary_nodes]
}

resource "kubernetes_deployment" "nginx"{
    metadata{
        name = "nginx-deployment"
        namespace = kubernetes_namespace.nginx.metadata[0].name
        labels = {
            app = "nginx"
        }
    }

    spec {
        replicas = 2

        selector{
            match_labels = {
                app = "nginx" 
            }
        } 

        template {
            metadata{
                labels ={
                    app = "nginx"
                }
            }

            spec{
                container { 
                    name = "nginx"
                    image = "nginx:latest"

                    port{
                        container_port = 80
                    }

                    liveness_probe{
                        http_get {
                            path = "/"
                            port = 80
                        }
                        initial_delay_seconds = 10
                        period_seconds = 5 
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "nginx"{
    metadata{
        name = "nginx-service"
        namespace = kubernetes_namespace.nginx.metadata[0].name
    }

    spec{
        selector = {
            app = "nginx"
        }

        port {
            port = 80
            target_port = 80
        }

        type = "LoadBalancer"
    }
}