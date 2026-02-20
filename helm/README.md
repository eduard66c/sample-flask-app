# Monitoring Stack with Helm

This directory contains a Helm-based setup for your monitoring stack using industry-standard Helm charts.

## Directory Structure

```
helm/
├── monitoring-stack/          # Main umbrella chart
│   ├── Chart.yaml            # Chart metadata and dependencies
│   └── values.yaml           # Configuration for all components
│
└── flask-app/                # Custom Flask app chart
    ├── Chart.yaml            # Chart metadata
    ├── values.yaml           # Default values
    └── templates/
        ├── deployment.yaml   # Flask + Promtail sidecar
        ├── service.yaml      # Kubernetes Service
        ├── configmap.yaml    # Promtail config
        └── _helpers.tpl      # Helm helpers
```

## What Each Chart Does

### monitoring-stack (Umbrella Chart)
- **kube-prometheus-stack**: Includes Prometheus, Grafana, Node Exporter, Kube State Metrics
- **loki-stack**: Includes Loki
- **flask-app**: Your custom Flask application with Promtail sidecar

### flask-app (Custom Chart)
- Flask application deployment
- Promtail as sidecar container
- Service exposure
- ConfigMap for Promtail configuration

## Prerequisites

1. **Kubernetes cluster** (v1.19+)
2. **Helm 3** installed: `helm version`
3. **kubectl** configured to access your cluster

## Quick Start

### 1. Add Helm Repositories

```bash
# Prometheus community charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Grafana charts
helm repo add grafana https://grafana.github.io/helm-charts

# Update repositories
helm repo update
```

### 2. Update Dependencies

```bash
cd helm/monitoring-stack
helm dependency update
```

This downloads the external charts (kube-prometheus-stack, loki-stack) defined in Chart.yaml.

### 3. Create Namespace

```bash
kubectl create namespace monitoring
```

### 4. Customize values.yaml

Edit `helm/monitoring-stack/values.yaml`:

```bash
# IMPORTANT: Update Flask image
# Find the line:
#   image:
#     repository: flask-app  # CHANGE THIS
# Replace with your actual image repository:
#   image:
#     repository: myregistry/my-flask-app
```

### 5. Dry Run (Validate)

```bash
cd helm/monitoring-stack
helm install monitoring . --namespace monitoring --dry-run --debug
```

This shows you what will be deployed without actually installing it.

### 6. Install the Stack

```bash
cd helm/monitoring-stack
helm install monitoring . --namespace monitoring
```

Or with custom values file:

```bash
helm install monitoring . --namespace monitoring -f values-production.yaml
```

### 7. Verify Installation

```bash
# Check all resources
kubectl get all -n monitoring

# Check PVCs
kubectl get pvc -n monitoring

# Watch pod startup
kubectl get pods -n monitoring -w

# Check specific pod logs
kubectl logs -n monitoring -f deployment/monitoring-prometheus-kube-prom-prometheus
kubectl logs -n monitoring -f deployment/monitoring-loki
kubectl logs -n monitoring -f deployment/flask-app
```

## Accessing Services

### Port Forwarding (Development)

```bash
# Grafana
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:3000

# Prometheus
kubectl port-forward -n monitoring svc/monitoring-kube-prom-prometheus 9090:9090

# Loki
kubectl port-forward -n monitoring svc/monitoring-loki 3100:3100
```

Then access:
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Loki**: http://localhost:3100

### Service DNS Names

Inside the cluster, services are available at:
- `monitoring-kube-prom-prometheus:9090` (Prometheus)
- `monitoring-grafana:3000` (Grafana)
- `monitoring-loki:3100` (Loki)
- `flask-app:5000` (Flask app)

## Configuration

### Changing Prometheus Scrape Interval

Edit `helm/monitoring-stack/values.yaml`:

```yaml
kubePrometheusStack:
  prometheus:
    prometheusSpec:
      scrapeInterval: 30s  # Change from default 15s
```

Then upgrade:

```bash
helm upgrade monitoring . --namespace monitoring
```

### Adjusting Storage Sizes

Edit storage values:

```yaml
kubePrometheusStack:
  prometheus:
    prometheusSpec:
      storageSpec:
        volumeClaimTemplate:
          spec:
            resources:
              requests:
                storage: 20Gi  # Increase to 20Gi

lokiStack:
  loki:
    persistence:
      size: 20Gi  # Increase to 20Gi
```

### Modifying Flask App

Update `flask-app` sub-chart in `values.yaml`:

```yaml
flaskApp:
  flaskApp:
    image:
      repository: myregistry/my-flask-app  # Update image
      tag: v1.2.3                          # Specify version
    
    env:
      FLASK_ENV: staging
      DEBUG: "false"
```

Then upgrade:

```bash
helm upgrade monitoring . --namespace monitoring
```

## Common Commands

### Install
```bash
helm install monitoring . --namespace monitoring
```

### Upgrade (after changing values.yaml)
```bash
helm upgrade monitoring . --namespace monitoring
```

### Check Values
```bash
helm values monitoring -n monitoring
```

### Get Release Info
```bash
helm status monitoring -n monitoring
```

### Rollback to Previous Release
```bash
helm rollback monitoring -n monitoring
```

### Uninstall
```bash
helm uninstall monitoring -n monitoring
```

## Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n monitoring

# Check logs
kubectl logs <pod-name> -n monitoring
```

### Storage issues

```bash
# Check PVCs
kubectl get pvc -n monitoring

# Describe PVC for errors
kubectl describe pvc <pvc-name> -n monitoring
```

### Chart dependency issues

```bash
# Update dependencies
helm dependency update

# Check dependencies
helm dependency list
```

### Helm template debugging

```bash
# See rendered templates before installing
helm template monitoring . --namespace monitoring > /tmp/manifests.yaml
cat /tmp/manifests.yaml
```

## Customization Examples

### values-production.yaml

Create `helm/monitoring-stack/values-production.yaml`:

```yaml
kubePrometheusStack:
  prometheus:
    prometheusSpec:
      retention: 30d
      resources:
        requests:
          cpu: 500m
          memory: 1Gi
        limits:
          cpu: 2000m
          memory: 4Gi

lokiStack:
  loki:
    persistence:
      size: 50Gi

flaskApp:
  flaskApp:
    image:
      tag: v1.0.0
    env:
      FLASK_ENV: production
  replicaCount: 3
```

Deploy with:

```bash
helm install monitoring . --namespace monitoring -f values-production.yaml
```

### Multiple Environments

```bash
# Development
helm install monitoring . --namespace monitoring -f values-dev.yaml

# Staging
helm install monitoring . --namespace monitoring -f values-staging.yaml

# Production
helm install monitoring . --namespace monitoring -f values-production.yaml
```

## Resources & Documentation

- **Helm Docs**: https://helm.sh/docs/
- **kube-prometheus-stack**: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
- **loki-stack**: https://github.com/grafana/helm-charts/tree/main/charts/loki-stack
- **Helm Best Practices**: https://helm.sh/docs/chart_best_practices/

## Next Steps

1. Update `flask-app` image repository in `values.yaml`
2. Run `helm dependency update`
3. Run `helm install monitoring . --namespace monitoring`
4. Access Grafana and add dashboards
5. Create alerts in Prometheus/AlertManager (if enabled)