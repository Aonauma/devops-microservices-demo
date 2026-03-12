# DevOps Microservices Demo

This project demonstrates a production-style microservices platform built using modern DevOps and Site Reliability Engineering (SRE) practices.

The system provisions infrastructure using Terraform, deploys containerized services to AWS EKS (Kubernetes), and integrates CI/CD, monitoring, and centralized logging.

---

# 1. Project Overview

This system deploys two microservices:

Frontend – React Web Application  
Backend – Node.js API Service  

The platform includes:

- Infrastructure as Code (Terraform)
- Containerization (Docker)
- Kubernetes orchestration (EKS)
- CI/CD automation (GitHub Actions)
- Monitoring (Prometheus + Grafana)
- Centralized logging (Loki + Fluent Bit)

---

# 2. Architecture Diagram

```
                         User
                          │
                          ▼
           AWS Application Load Balancer (ALB)
                          │
                          ▼
                    Kubernetes Ingress
                          │
                          ▼
              Kubernetes Cluster (AWS EKS)
       ┌────────────────────┼────────────────────┐
       │                    │                    │
       ▼                    ▼                    ▼
Frontend Pod(s)        Backend Pod(s)      Monitoring Pod(s)
   (React)              (Node.js)      Prometheus / Grafana / Loki
```

---

# 3. Technology Stack

| Layer | Technology |
|------|------------|
| Cloud | AWS |
| Infrastructure | Terraform |
| Container | Docker |
| Registry | Amazon ECR |
| Orchestration | Kubernetes (EKS) |
| CI/CD | GitHub Actions |
| Backend | Node.js |
| Frontend | React |
| Monitoring | Prometheus |
| Logging | Loki + Fluent Bit |

---

# 4. Repository Structure

```text
devops-microservices-demo
├── api/                     # Node.js backend service
├── web/                     # React frontend application
├── infra/                   # Terraform infrastructure
│   ├── modules/             # Reusable Terraform modules
│   │   ├── vpc
│   │   ├── eks
│   │   └── ecr
│   └── envs/
│       └── dev              # Environment configuration
├── deploy/                  # Kubernetes deployment configuration
│   ├── kustomization/       # Base and overlay manifests
│   │   ├── base
│   │   └── overlays
│   └── monitoring/          # Observability configuration
│       ├── grafana-values.yaml
│       ├── loki-values.yaml
│       └── fluent-bit-values.yaml
├── .github/
│   └── workflows/           # CI/CD pipelines
│       ├── pr.yml
│       ├── build.yml
│       └── deploy.yml
├── docker-compose.yml       # Local development environment
├── .gitignore
└── README.md

```

---

# 5. Infrastructure as Code (Terraform)

Infrastructure is provisioned using Terraform.

Resources created include:

- VPC
- Public / Private Subnets
- EKS Cluster
- Worker Nodes
- Security Groups
- Application Load Balancer

Deploy infrastructure:

```
cd infra
terraform init
terraform apply
```

---

# 6. Containerization

Both services are containerized using Docker multi-stage builds.

Example backend Dockerfile:

```
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json .
RUN npm install

COPY . .

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app .
CMD ["node","app.js"]
```

Benefits:

- Smaller production image
- Faster build
- Secure container environment

---

# 7. Container Registry

Docker images are stored in Amazon ECR.

Repositories:

```
devops-microservice-demo-api
devops-microservice-demo-web
```

Images are pushed automatically through CI/CD.

---

# 8. CI/CD Pipeline

CI/CD is implemented using GitHub Actions.

Pipeline runs automatically when pushing to the main branch.

## CI/CD Flow

```
Developer Push Code
        │
        ▼
GitHub Repository
        │
        ▼
GitHub Actions Pipeline
        │
        ▼
    Build App
        │
        ▼
    Docker Build
        │
        ▼
Push Image → Amazon ECR
        │
        ▼
Deploy → Kubernetes (EKS)
```

Pipeline responsibilities:

- build application
- build Docker images
- push images to ECR
- deploy to Kubernetes

---

# 9. Kubernetes Deployment

Applications are deployed to AWS EKS.

Kubernetes resources:

- Deployment
- Service
- Ingress
- Namespace

Deploy application:

```
kubectl apply -k deploy/kustomization/overlays/<env>
```
---

# 10. Observability

This platform includes a full observability stack.

Metrics

Prometheus collects:

- application metrics
- container metrics
- node metrics

Visualization

Grafana dashboards provide visibility into:

- CPU usage
- memory usage
- request rate
- service availability

---

# 11. Logging

Centralized logging stack:

Fluent Bit → Log collector  
Loki → Log storage  
Grafana → Log visualization  

Logs collected include:

- application logs
- container logs
- Kubernetes logs

---

# 12. Implement Steps

12.1 Provision Core Infrastructure

```
cd infra/envs/dev
terraform init
terraform plan
terraform apply \
  -var="enable_lb_controller=false" \
  -var="enable_eks_access=false"
```
Terraform provisions:

- VPC
- Subnets
- EKS Cluster
- ECR repositories

12.2 Install Cluster Add-ons

```
terraform apply \
  -var="enable_lb_controller=true" \
  -var="enable_eks_access=true"
```

Terraform provisions:

- aws_eks_access_entry
- aws_eks_access_policy_association
- aws_iam_role for Load Balancer Controller
- kubernetes_service_account
- helm_release for AWS Load Balancer Controller

12.3 Configure Kubernetes

```
aws eks update-kubeconfig --region ap-southeast-7 --name devops-microservice-demo
```
Verify cluster:

```
kubectl get nodes
```

12.4 Create Namespace for application

```
kubectl create namespace demo
```

Verify:

```
kubectl get ns
```

12.5 Deploy Application

Deployment is automated through **GitHub Actions CI/CD pipeline**.

Push code to trigger deployment:

```
git push origin main
```

12.6 Verify Deployment

Check pods:

```
kubectl get pods -n demo
```

Check services:

```
kubectl get svc -n demo
```

Check ingress:

```
kubectl get ingress -n demo
```

**Application Endpoints**

| Endpoint | Description |
|---|---|
| /health | Health check |
| /ready | Readiness probe |
| /metrics | Prometheus metrics |
| /api/message | Demo API endpoint |


12.7 Monitoring Setup

Monitoring is implemented using **kube-prometheus-stack**, which installs the following components:

- Prometheus
- Grafana
- Node Exporter
- kube-state-metrics
- Alertmanager

**Create Namespace for monitoring**

```
kubectl create namespace monitoring
```

Verify:

```
kubectl get ns
```

**Install Monitoring Stack**

Add Helm repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Install kube-prometheus-stack

```bash
cd ../../../
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
-n monitoring \
-f deploy/monitoring/grafana-values.yaml
```

**Verify Monitoring Components**

Check monitoring namespace

```bash
kubectl get pods -n monitoring
```

Expected components include:

- prometheus
- grafana
- kube-state-metrics
- node-exporter

**Access Grafana**

Expose Grafana locally using port-forward

```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

Open in browser

```
http://localhost:3000
```

Dashboard: Kubernetes / Compute Resources / Namespace (Pods)

<p align="center">
<img width="1900" height="958" alt="image" src="https://github.com/user-attachments/assets/4d3eb2cb-6b3c-455d-888e-bc73e045d568" />
</p>

Dashboard: Kubernetes / Compute Resources / Pod

<p align="center">
<img width="1910" height="951" alt="image" src="https://github.com/user-attachments/assets/d997d22c-04d4-4315-bfa3-e8c477033b6a" />
</p>

Dashboard: Node Exporter / Nodes

<p align="center">
<img width="1907" height="957" alt="image" src="https://github.com/user-attachments/assets/5bf1c95b-a3af-4c90-b8c0-3f3090306545" />
</p>

**Alerting**

Basic alerting is implemented using **Prometheus Alert Rules** provided by the `kube-prometheus-stack`.  
These rules monitor workloads in the **`demo` namespace** and detect abnormal conditions such as container crashes, high CPU usage, and service readiness failures.

**Access Prometheus**
```
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090 -n monitoring
```

Open in browser
```
http://localhost:9090/alerts
```

Example
**PodNotReady**

Detects when a pod remains in a non-ready state and cannot serve traffic.

PromQL rule

kube_pod_status_ready{condition="true", namespace="demo"} == 0

<p align="center">
<img width="1905" height="837" alt="image" src="https://github.com/user-attachments/assets/c17a1a3b-3d68-4d95-95dc-f2f8d1bbbc13" />
</p>

12.8 Logging Setup

Centralized logging is implemented using **Loki** and **Fluent Bit**.

Logging pipeline architecture

```
Kubernetes Pods
        ↓
Fluent Bit (log collector)
        ↓
Loki (log storage)
        ↓
Grafana (log exploration)
```

**Install Loki**

Add Helm repository

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

Install Loki

```bash
helm upgrade --install loki grafana/loki \
-n monitoring \
-f deploy/monitoring/loki-values.yaml
```

Verify Loki pods

```bash
kubectl get pods -n monitoring
```

Add Data source for Loki

<p align="center">
<img width="1419" height="842" alt="image" src="https://github.com/user-attachments/assets/e04fdf87-0865-49af-bf16-73464b373801" />
</p>

**Deploy Fluent Bit**

Fluent Bit runs as a **DaemonSet** to collect logs from Kubernetes nodes.

```bash
helm upgrade --install fluent-bit fluent/fluent-bit \
-n monitoring \
-f deploy/monitoring/fluent-bit-values.yaml
```

Verify Fluent Bit

```bash
kubectl get pods -n monitoring
```

Each node should have one Fluent Bit pod running.


12.9 Verify Logs in Grafana

Open **Grafana → Explore**

Query logs from the `demo` namespace

```
{kubernetes_namespace_name="demo"}
```

<p align="center">
<img width="1200" src="https://github.com/user-attachments/assets/d7d49262-c312-4b23-b50d-67ab8043258a">
</p>


Example query for API startup logs

```
{kubernetes_namespace_name="demo", kubernetes_container_name="api"} |= "api_started"
```

<p align="center">
<img width="1658" height="861" alt="image" src="https://github.com/user-attachments/assets/acc69cc1-7b2a-441f-b38e-2a71864f476d" />
</p>

Example log entry

```
{"msg":"api_started","port":"3000","version":"V1","env":"production"}
```

Restart the API to generate new logs

```bash
kubectl rollout restart deployment api -n demo
```

Logs will appear in Grafana in real time.

## URLs Verify

After deployment, the following endpoints can be used to verify the system.

### Application

Frontend

```
http://<application-loadbalancer-url>
```

Backend API

```
http://<application-loadbalancer-url>/api/message
```

---

### Health & Metrics

Health check

```
http://<application-loadbalancer-url>/health
```

Metrics

```
http://<application-loadbalancer-url>/metrics
```

---

### Monitoring

Grafana

```
http://<grafana-loadbalancer-url>:80
```

Default credentials

```
username: admin
password: admin123
```

---

test me
