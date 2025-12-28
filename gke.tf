resource "google_container_cluster" "primary" {
    name = var.cluster_name
    location = var.zone

    remove_default_node_pool = true
    initial_node_count = 1

    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name

    ip_allocation_policy{
        cluster_secondary_range_name = "pods"
        services_secondary_range_name = "services"
    }

    workload_identity_config {
        workload_pool = "${var.project_id}.svc.id.goog"
    }

    logging_service = "logging.googleapis.com/kubernetes"
    monitoring_service = "monitoring.googleapis.com/kubernetes"

    network_policy{
        enabled = true 
    }

    addons_config{
        http_load_balancing {
            disabled = false
        }

        horizontal_pod_autoscaling{
            disabled = false
        }

        network_policy_config{
            disabled = false 
        }
    }

    deletion_protection = false
}

resource "google_container_node_pool" "primary_nodes"{
    name = "${var.cluster_name}-node-pool"
    location = var.zone
    cluster = google_container_cluster.primary.name

    node_count = var.node_count

    node_config{
        machine_type = var.machine_type
        disk_size_gb = 50
        disk_type = "pd-standard"

        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]

        labels = {
            env = "dev"
        }

        tags = ["gke-node", var.cluster_name]

        workload_metadata_config{
            mode = "GKE_METADATA"
        }
    }

    management{
        auto_repair = true
        auto_upgrade = true
    }

    autoscaling{
        min_node_count = 1
        max_node_count = 2 
    }
}