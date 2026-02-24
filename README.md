# Prometheus Monitoring stack

**Status:** Work in Progress 🚧

This project is based on a single-file Flask app with custom logging configured + the necessary components to gather its metrics and logs. 

The intent is to implement the stack using Docker Compose, K8s manifests, Helm charts, and GCP resources provisioned with Terraform.



## Technologies

- Containerized deployments using docker-compose, K8s, Helm
- Prometheus (metrics collection)
- Grafana (visualization)
- Node Exporter (system metrics)
- Python Flask (application metrics)
- Helm charts for packaging deployments

## Quick Start

Docker Compose:
```bash
docker-compose up -d
```
Kubernetes:
```bash
cd ./kubernetes
kubectl apply -f .
kubectl port-forward service/grafana 3000:3000
```
Helm:
```bash
helm install loki grafana/loki-stack -f helm/values-loki.yaml -n monitoring
helm install prometheus prometheus-community/kube-prometheus-stack -f helm/values-prometheus.yaml -n monitoring
helm install flask-app helm/flask-app -n monitoring
```

Access services:
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090 (requires port-forward if using K8s setup)

## Next Steps

- [ ] Move the setup to a Cloud environment using Terraform

---

*This is an active learning project being developed to demonstrate DevOps and SRE practices.*