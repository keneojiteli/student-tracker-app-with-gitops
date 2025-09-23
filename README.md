## Student Tracker App with GitOps and Observability Implemented

This repo shows a Python app deployment to a Kubernetes cluster using Helm, GitHub Actions and ArgoCD and also monitoring and observability with Prometheus, Loki and Tempo and Grafana for Visualisation (a working solution for monitoring & observability can be found on the monitoring branch).

## Prerequisites

[Application repo](https://github.com/keneojiteli/student-tracker-devops-project)

This project provisions a full monitoring stack on a Kubernetes cluster using GitOps with ArgoCD. It includes:

- ArgoCD → GitOps control plane
- Kube-Prometheus-Stack → Prometheus, Alertmanager, Grafana
- Loki → Logs aggregation with Promtail
- Tempo → Distributed tracing
- Student Progress App → Sample FastAPI app instrumented with health checks & metrics
---
  ## 📁 File Structure
```
student-tracker-app-with-gitops-and-monitoring/
├── .github/                        # GitHub configuration
│   └── workflows/                  # GitHub Actions workflows
│       └── build-image.yml         # CD pipeline for Docker build & push + bump helm charts
│
├── argocd/                            # Application source code
│   └── * [Monitoring stack for argocd]  # monitoring app for argocd
│   ├── argo-values.yaml               # disables security features like TLS/SSL certificate validation/authentication
│   ├── student-tracker.yaml           # student tracker application for argocd
│
├── root/
│   └── app-ofapps.yaml  # root file to deploy other apps to argocd
|
├── src/
│   └── * [Source code of the FastAPI-app]  # includes app and templates
|
├── charts/                         # Helm charts for Kubernetes
│   └── student-tracker-chart/      # Custom Helm chart for the app
│       ├── Chart.yaml              # Chart metadata
│       ├── values.yaml             # Default configuration values
│       ├── my-values.yaml          # Custom overrides for environment
│       └── templates/              # Kubernetes manifests (templated)
│           ├── deployment.yaml     # Deployment for the app
│           ├── ingress.yaml        # Ingress rules for external access
│           ├── secret.yaml         # Secrets for app config
│           ├── service.yaml        # Service definition
│           ├── serviceaccount.yaml # Service account definition
│           └── _helpers.tpl        # Template helper functions
│
│
├── .gitignore                      # Git ignore rules
├── Dockerfile                      # Docker build instructions
├── README.md                       # Project documentation
└── requirements.txt                # Python dependencies

```
## Overview
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Student       │    │   Prometheus    │    │    Grafana      │
│   Tracker App   │───▶│   (Metrics)     │───▶│  (Dashboards)   │
│   (FastAPI)     │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       ▲                       ▲
         │                       │                       │
         ▼                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MongoDB       │    │   Loki +        │    │   AlertManager  │
│   (Database)    │    │   Promtail      │    │   (Alerts)      │
│                 │    │   (Logs)        │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```
## Deployment Flow
- Push changes to GitHub: Commit and push your manifests/Helm configs to the GitOps repo.
- Bootstrap with App of Apps: ```kubectl apply -f argo/root/app-of-apps.yaml -n argocd```, This creates a root ArgoCD Application that manages child apps.
- ArgoCD Syncs Automatically: kube-prometheus-stack → Prometheus, Grafana, Alertmanager; loki → Loki + Promtail (logs); tempo → Tempo (tracing)
- Verify Deployments: kubectl -n monitoring get pods, Ensure all monitoring components are up and running.

## Accessing the UI
#### ArgoCD UI
- Port-forward the ArgoCD server service: `kubectl -n argocd port-forward svc/argo-cd-argocd-server 8080:80 --address 0.0.0.0`
- Access in your browser: `http://<your-VM-public-IP>:8080`
- Get the initial admin password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`
  - Username: admin
  - Password: output from the command above
    
#### Grafana UI
- Port-forward the Grafana service: `kubectl -n monitoring port-forward svc/kps-grafana 3000:80 --address 0.0.0.0`
- Access in your browser: `http://<your-VM-public-IP>:3000`
- Get the initial admin password: `kubectl -n monitoring get secret <secret_name> -o jsonpath="{.data.admin-password}" | base64 -d; echo`
  - Username: admin
  - Password: admin or output from the command above 
