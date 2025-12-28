# IMPORTANT: Replace with YOUR actual project ID
project_id = "high-form-479315-n2"

# You can override other defaults here if needed
region       = "asia-south1"
zone         = "asia-south1-a"
cluster_name = "my-gke-cluster"
node_count   = 2
machine_type = "e2-medium"

enable_argocd       = true
website_repo_url    = "https://github.com/Himansri21/your-website-repo"  # Replace with your actual website repo
website_repo_path   = "k8s"  # Where your K8s manifests are in the repo
website_namespace   = "production"
