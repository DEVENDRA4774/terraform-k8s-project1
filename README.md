# Automated Kubernetes & Cloud Infrastructure on AWS with Terraform and CI/CD

An end-to-end DevOps project provisioning AWS cloud infrastructure using Terraform, running a Lightweight Kubernetes (`k3s`) cluster on EC2 with a managed PostgreSQL RDS database, and deploying applications automatically via GitHub Actions CI/CD pipelines.

---

## 🏗️ Architecture Overview

```mermaid
flowchart TD
    subgraph Dev["1. Developer Workflow"]
        A["💻 Code Changes<br/>(app.py / Dockerfile)"] -->|git push origin main| B["🐙 GitHub Repository"]
    end

    subgraph CICD["2. Automated CI/CD Pipeline (GitHub Actions)"]
        B -->|Triggers Workflow| C["⚙️ GitHub Actions Runner"]
        C -->|1. Checkout & Build| D["🐳 Docker Build<br/>(devendra4774/myapp:latest)"]
        D -->|2. Push Image| E["📦 Docker Hub Registry"]
        C -->|3. SSH Command| F["🔐 SSH to EC2<br/>(appleboy/ssh-action)"]
    end

    subgraph AWS["3. AWS Cloud Infrastructure (Terraform Provisioned)"]
        subgraph VPC["VPC (10.0.0.0/16)"]
            subgraph PublicSubnet["Public Subnet 1 (us-east-1a)"]
                F -->|kubectl rollout restart| G["🖥️ EC2 Instance (t3.small)<br/>k3s Node"]
                G -->|Pull Image| E
                G -->|Runs| H["☸️ k3s Kubernetes Cluster"]
                H -->|Container Replicas| I["📦 App Pods (Nginx / Flask)"]
            end
            
            subgraph PrivateDB["DB Subnet Group (us-east-1a / us-east-1b)"]
                I -->|Port 5432| K[("🗄️ AWS RDS PostgreSQL<br/>(appdb)")]
            end
        end
    end

    subgraph Users["4. End User Access"]
        L["🌐 Public Web Users"] -->|http://EC2_PUBLIC_IP:30080| G
    end
```

---

## 🚀 Key Features

- **Infrastructure as Code (IaC)**: Modular Terraform configurations provisioning VPC, Multi-AZ subnets, Internet Gateway, Security Groups, EC2 instance, and RDS database.
- **Lightweight Kubernetes Cluster**: Single-node `k3s` cluster running on Ubuntu 22.04 LTS (`t3.small`).
- **Managed Relational Database**: AWS RDS PostgreSQL 15 (`db.t3.micro`) secured in a private DB subnet group, accepting incoming connections exclusively from the EC2 security group on port 5432.
- **Automated CI/CD**: GitHub Actions workflow building Docker images, pushing to Docker Hub, and executing zero-downtime rolling restarts on the Kubernetes cluster upon code push to `main`.

---

## 📁 Repository Structure

```text
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD Pipeline
├── app/
│   ├── app.py                  # Flask REST API Application (GET/POST /notes)
│   ├── Dockerfile              # Docker container image definition
│   └── requirements.txt        # Python dependencies
├── terraform/
│   ├── main.tf                 # Core AWS infrastructure (VPC, EC2, RDS, SG)
│   ├── outputs.tf              # Infrastructure outputs (IPs, endpoints)
│   └── variables.tf            # Configurable variables and parameters
├── deployment.yaml             # Kubernetes Deployment manifest
├── service.yaml                # Kubernetes NodePort Service manifest (Port 30080)
├── app-deployment.yaml         # Flask App Kubernetes Deployment manifest
├── app-service.yaml            # Flask App Kubernetes Service manifest
└── screenshots/                # Deployment verification screenshots
```

---

## 🛠️ Infrastructure Component Breakdown

### 1. Networking & Security Group Rules
- **VPC CIDR**: `10.0.0.0/16`
- **Public Subnet 1**: `10.0.1.0/24` in `us-east-1a`
- **Public Subnet 2**: `10.0.2.0/24` in `us-east-1b`
- **EC2 Security Group (`proj1-sg`)**:
  - Ingress TCP `22`: SSH access for administration & GitHub Actions runners
  - Ingress TCP `30000-32767`: Kubernetes NodePort range (Exposing port `30080`)
- **RDS Security Group (`proj1-rds-sg`)**:
  - Ingress TCP `5432`: PostgreSQL traffic restricted strictly to source EC2 Security Group (`proj1-sg`)

### 2. Compute & Kubernetes
- **Instance Type**: `t3.small` (2 vCPU, 2 GiB RAM)
- **OS**: Ubuntu Server 22.04 LTS (`al2023` / Jammy AMD64)
- **Cluster Bootstrap**: Automated `k3s` installation via EC2 `user_data` script.

### 3. Database
- **Engine**: PostgreSQL 15 (`db.t3.micro`)
- **Database Name**: `appdb`
- **Master User**: `appadmin`
- **Storage**: 20 GB GP3 EBS

---

## ⚙️ Quick Start Guide

### Prerequisites
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (v1.0+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with valid credentials (`aws configure`)
- [Docker](https://www.docker.com/) & [Git](https://git-scm.com/)

### 1. Provision AWS Infrastructure
```bash
cd terraform
terraform init
terraform plan -var="db_password=YourStrongPassword123" -var="my_ip=YOUR_IP/32"
terraform apply -var="db_password=YourStrongPassword123" -var="my_ip=YOUR_IP/32" -auto-approve
```

### 2. Configure GitHub Actions Secrets
In your GitHub repository under **Settings → Secrets and variables → Actions**, add:

| Secret Name | Description | Example Value |
|---|---|---|
| `DOCKERHUB_USERNAME` | Docker Hub Account Username | `devendra4774` |
| `DOCKERHUB_TOKEN` | Docker Hub Access Token | `dckr_pat_xxx...` |
| `EC2_HOST` | EC2 Instance Public IP | `3.208.87.68` |
| `EC2_SSH_KEY` | Contents of `~/.ssh/id_rsa` Private Key | `-----BEGIN OPENSSH PRIVATE KEY----- ...` |

### 3. Deploy Applications to Cluster
```bash
# Connect to EC2
ssh -i ~/.ssh/id_rsa ubuntu@<EC2_PUBLIC_IP>

# Verify k3s nodes
sudo kubectl get nodes

# Apply K8s Manifests
sudo kubectl apply -f deployment.yaml -f service.yaml
```

### 4. Cleanup & Resource Termination
```bash
cd terraform
terraform destroy -var="db_password=YourStrongPassword123" -var="my_ip=YOUR_IP/32" -auto-approve
```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
