# Helm Monitoring Stack - Quick Reference

## Setup (One Time)

```bash
# 1. Add repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 2. Create namespace
kubectl create namespace monitoring

# 3. Update dependencies
cd helm/monitoring-stack
helm dependency update

# 4. Update values.yaml with your Flask image
# Edit: flask-app.image.repository
```

## Install

```bash
# Development
helm install monitoring . --namespace monitoring -f values-dev.yaml

# Production
helm install monitoring . --namespace monitoring -f values-production.yaml

# With debug info
helm install monitoring . --namespace monitoring --debug
```

## Upgrade

```bash
# After changing values.yaml
helm upgrade monitoring . --namespace monitoring

# After changing values-dev.yaml
helm upgrade monitoring . --namespace monitoring -f values-dev.yaml

# Rollback to previous version
helm rollback monitoring 1 --namespace monitoring
```

## Verify

```bash
# Check release status
helm status monitoring --namespace monitoring

# List all resources
kubectl get all --namespace monitoring

# Check logs
kubectl logs -n monitoring -f deployment/flask-app -c flask-app
kubectl logs -n monitoring -f deployment/monitoring-loki
```

## Access Services

```bash
# Grafana (admin/admin)
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:3000

# Prometheus
kubectl port-forward -n monitoring svc/monitoring-kube-prom-prometheus 9090:9090

# Loki
kubectl port-forward -n monitoring svc/monitoring-loki 3100:3100
```

## Uninstall

```bash
# Remove the release
helm uninstall monitoring --namespace monitoring

# Delete namespace
kubectl delete namespace monitoring
```

## Debug

```bash
# Dry run (see what will be installed)
helm install monitoring . --namespace monitoring --dry-run --debug

# Template rendering (save to file)
helm template monitoring . > manifests.yaml
cat manifests.yaml

# Check template values
helm values monitoring --namespace monitoring
```

## Update Flask App Only

```bash
# Edit values.yaml with new image tag
# flaskApp.flaskApp.image.tag: v1.1.0

# Upgrade just the Flask chart
helm upgrade monitoring . --namespace monitoring
```

## Common Issues

### Pods stuck in Pending
```bash
# Check PVC status
kubectl get pvc --namespace monitoring

# Check node resources
kubectl top nodes
```

### Services not accessible
```bash
# Check service endpoints
kubectl get endpoints --namespace monitoring

# Test DNS
kubectl exec -it deployment/flask-app -n monitoring -- nslookup loki
```

### Failed deployment
```bash
# Check detailed pod info
kubectl describe pod <pod-name> --namespace monitoring

# Check recent events
kubectl get events --namespace monitoring --sort-by='.lastTimestamp'
```

## Environment-Specific Overrides

```bash
# Using multiple value files (later values override earlier)
helm install monitoring . \
  --namespace monitoring \
  -f values.yaml \
  -f values-prod-overrides.yaml

# Inline value overrides
helm install monitoring . \
  --namespace monitoring \
  --set flaskApp.replicaCount=3 \
  --set kubePrometheusStack.prometheus.prometheusSpec.retention=60d
```

## Helm Chart Management

```bash
# List installed releases
helm list --namespace monitoring

# Show release history
helm history monitoring --namespace monitoring

# Rollback to specific revision
helm rollback monitoring 2 --namespace monitoring

# Get rendered manifests
helm get values monitoring --namespace monitoring
helm get manifest monitoring --namespace monitoring
```