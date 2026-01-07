# GKE Cluster with ArgoCD GitOps Pipeline

[![Terraform](https://img.shields.io/badge/Terraform-1.x-623CE4?logo=terraform)](https://www.terraform.io/)
[![GCP](https://img.shields.io/badge/GCP-Cloud-4285F4?logo=google-cloud)](https://cloud.google.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.27+-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-2.x-EF7B4D?logo=argo)](https://argoproj.github.io/cd/)

A complete Infrastructure as Code (IaC) solution for deploying a production-ready Google Kubernetes Engine (GKE) cluster with ArgoCD for GitOps-based continuous deployment.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [ArgoCD Setup](#argocd-setup)
- [Cost Optimization](#cost-optimization)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Contributing](#contributing)

## 🎯 Overview

This project provides a fully automated infrastructure setup for running containerized applications on Google Cloud Platform using:

- **Terraform** for infrastructure provisioning
- **GKE** for managed Kubernetes cluster
- **ArgoCD** for GitOps-based application deployment
- **VPC networking** with proper segmentation
- **Auto-scaling** node pools for cost efficiency

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     GCP Project                         |
│                                                         │
│  ┌────────────────────────────────────────────────┐     │
│  │              VPC Network                       │     │
│  │                                                │     │
│  │  ┌──────────────────────────────────────────┐  │     │
│  │  │         Subnet (10.10.0.0/24)            │  │     │
│  │  │                                          │  │     │
│  │  │  ┌────────────────────────────────┐      │  │     │
│  │  │  │      GKE Cluster               │      │  │     │
│  │  │  │                                │      │  │     │
│  │  │  │  ├─ Node Pool (Auto-scaling)   │      │  │     │
│  │  │  │  │  └─ e2-standard-2 (1-3)     │      │  │     │
│  │  │  │  │                             |      │  │     │
│  │  │  │  ├─ ArgoCD Namespace           │      │  │     │
│  │  │  │  │  └─ ArgoCD Server (LB)      │      │  │     │
│  │  │  │  │                             │      │  │     │
│  │  │  │  └─ Application Namespaces     │      │  │     │
│  │  │  │     └─ Your Applications       │      │  │     │
│  │  │  └─────────────────────────────────┘     │  │     │
│  │  │                                          │  │     │
│  │  │  Secondary IP Ranges:                    │  │     │
│  │  │  ├─ Pods: 10.20.0.0/16                   │  │     │
│  │  │  └─ Services: 10.30.0.0/16               │  │     │ 
│  │  └──────────────────────────────────────────┘  │     │
│  └────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

## ✨ Features

### Infrastructure
- ✅ GKE cluster with Workload Identity enabled
- ✅ Custom VPC with dedicated subnet
- ✅ Secondary IP ranges for pods and services
- ✅ Auto-scaling node pools (1-3 nodes)
- ✅ Network policies enabled
- ✅ Cloud Monitoring & Logging integrated

### GitOps
- ✅ ArgoCD deployment via Helm
- ✅ App-of-Apps pattern support
- ✅ Automated sync and self-healing
- ✅ Multi-repository support
- ✅ NGINX Ingress Controller

### Security
- ✅ Workload Identity for service authentication
- ✅ Network policies for pod isolation
- ✅ Private cluster option
- ✅ Firewall rules for internal communication

### Operations
- ✅ Auto-repair and auto-upgrade enabled
- ✅ Resource limits and requests configured
- ✅ Cost-optimized machine types
- ✅ Easy cleanup and teardown

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (gcloud CLI)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- A GCP account with billing enabled
- GitHub account (for ArgoCD repositories)

### GCP Setup

1. **Create a GCP Project** (or use existing):
   ```bash
   gcloud projects create YOUR_PROJECT_ID
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Enable Required APIs**:
   ```bash
   gcloud services enable container.googleapis.com
   gcloud services enable compute.googleapis.com
   gcloud services enable servicenetworking.googleapis.com
   ```

3. **Set up Authentication**:
   ```bash
   gcloud auth application-default login
   ```

4. **Set up Billing** (if not already done):
   - Go to [GCP Console](https://console.cloud.google.com/)
   - Navigate to Billing and link your project

## 📁 Project Structure

```
.
├── README.md                      # This file
├── terraform/                     # Terraform infrastructure code
│   ├── providers.tf              # Provider configurations
│   ├── variables.tf              # Input variables
│   ├── outputs.tf                # Output values
│   ├── terraform.tfvars.example  # Example variable values
│   ├── network.tf                # VPC and networking resources
│   ├── gke.tf                    # GKE cluster configuration
│   ├── argocd.tf                 # ArgoCD Helm deployment
│   └── nginx.tf                  # NGINX Ingress Controller
│
├── argocd-apps/                   # ArgoCD Application manifests
│   ├── argocd-app.yaml           # ArgoCD self-management
│   ├── root-app.yaml             # Root App-of-Apps
│   └── website-app.yaml          # Example application
│
├── .gitignore                     # Git ignore rules
└── LICENSE                        # Project license
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Himansri21/GCP-cluster-terraform.git
cd GCP-cluster-terraform
```

### 2. Configure Variables

Create your `terraform.tfvars` file:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
project_id   = "your-gcp-project-id"
region       = "asia-south1"
zone         = "asia-south1-a"
cluster_name = "my-gke-cluster"
node_count   = 2
machine_type = "e2-standard-2"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Deploy Infrastructure

```bash
terraform apply
```

This will create:
- VPC network with subnets
- GKE cluster with node pool
- ArgoCD installation
- NGINX Ingress Controller

**Deployment time**: Approximately 10-15 minutes

### 6. Configure kubectl

```bash
gcloud container clusters get-credentials $(terraform output -raw cluster_name) \
  --zone $(terraform output -raw cluster_zone) \
  --project $(terraform output -raw project_id)
```

### 7. Access ArgoCD

Get the ArgoCD initial admin password:

```bash
# Password is available from Terraform output
terraform output argocd_admin_password

# Or get it directly from Kubernetes
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

Get the ArgoCD server external IP:

```bash
kubectl get svc argocd-server -n argocd
```

Access ArgoCD UI:
- URL: `http://<EXTERNAL-IP>`
- Username: `admin`
- Password: (from above command)

## ⚙️ Configuration

### Customizing Resources

Edit the respective `.tf` files:

- **Node pool size**: Modify `gke.tf` → `autoscaling` block
- **Machine type**: Change in `variables.tf` or `terraform.tfvars`
- **Network ranges**: Update `network.tf` CIDR blocks
- **ArgoCD resources**: Adjust `argocd.tf` values block

## 📊 Outputs

After deployment, Terraform provides:

```bash
terraform output

# Example outputs:
cluster_name           = "my-gke-cluster"
cluster_endpoint       = "35.200.xxx.xxx"
project_id             = "your-project-id"
region                 = "asia-south1"
zone                   = "asia-south1-a"
argocd_server_ip       = "34.93.xxx.xxx"
argocd_admin_password  = "<sensitive>"
```

## 🔄 ArgoCD Setup

### Deploy Applications with ArgoCD

1. **Fork/Clone your application repository**

2. **Update ArgoCD application manifests** in `argocd-apps/`:

   ```yaml
   # argocd-apps/website-app.yaml
   spec:
     source:
       repoURL: https://github.com/YOUR_USERNAME/your-app-repo
       targetRevision: main
       path: k8s
   ```

3. **Apply the App-of-Apps pattern**:

   ```bash
   kubectl apply -f argocd-apps/root-app.yaml
   ```

4. **Monitor deployment** in ArgoCD UI

For detailed ArgoCD setup, see [docs/ARGOCD_SETUP.md](docs/ARGOCD_SETUP.md)

## 💰 Cost Optimization

### Current Setup Cost (Approximate)

- **GKE Cluster Management**: ~$73/month
- **2x e2-standard-2 nodes**: ~$50/month
- **Networking**: ~$10/month
- **Total**: ~$133/month

### Cost Reduction Tips

1. **Use Spot/Preemptible nodes** for non-production:
   ```hcl
   node_config {
     spot = true
   }
   ```

2. **Reduce node count** to 1 for development

3. **Use smaller machine types** (`e2-small`, `e2-medium`)

4. **Enable cluster autoscaling** to scale to zero when unused

5. **Set up auto-shutdown** for dev environments

## 🔒 Security Best Practices

- ✅ Use Workload Identity instead of service account keys
- ✅ Enable Binary Authorization for image validation
- ✅ Implement Pod Security Standards
- ✅ Regular updates with auto-upgrade enabled
- ✅ Network policies for pod-to-pod communication
- ✅ Private cluster for production workloads
- ✅ Secret management with Google Secret Manager

## 🐛 Troubleshooting

### Common Issues

**1. Terraform authentication errors**
```bash
gcloud auth application-default login
```

**2. Insufficient permissions**
- Ensure you have `roles/container.admin` and `roles/compute.admin`

**3. ArgoCD not accessible**
```bash
# Check service status
kubectl get svc -n argocd
kubectl get pods -n argocd

# Check events
kubectl get events -n argocd
```

**4. Node pool not scaling**
- Verify auto-scaling configuration in GKE console
- Check cluster autoscaler logs

For more troubleshooting, see [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 🧹 Cleanup

To destroy all resources and avoid charges:

```bash
# Delete ArgoCD applications first (if any)
kubectl delete -f argocd-apps/

# Destroy Terraform infrastructure
terraform destroy

# Verify all resources are deleted
gcloud compute instances list
gcloud container clusters list
```

**Warning**: This will permanently delete all resources including data!

## 📚 Additional Resources

- [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Himanshu Srivastava**
- GitHub: [@Himansri21](https://github.com/Himansri21)
- LinkedIn: [Himanshu Srivastava](https://www.linkedin.com/in/himansri21/)
- Medium: [@himanshuSrivastava21]([https://medium.com/@himansrivastava2003])

## ⭐ Show your support

Give a ⭐️ if this project helped you!

---

**Note**: This is a development/learning setup. For production deployments, additional security hardening, monitoring, and backup strategies should be implemented.
