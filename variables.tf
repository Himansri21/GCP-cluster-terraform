variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-south1"    # Mumbai - closest to you in India
}

# Specific zone within the region
variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "asia-south1-a"
}

# Name for your Kubernetes cluster
variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  default     = "my-gke-cluster"
}

# How many worker nodes (VMs) to run
variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 2    # 2 nodes is good for learning
}

# Size of the VMs
variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"    # 2 vCPU, 4GB RAM - cost effective
}