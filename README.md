# Prometheus Monitoring stack

**Status:** Work in Progress 🚧

This project is based on a single-file Flask app with custom logging configured + the necessary components to gather its metrics and logs. 

The intent is to implement the stack using Docker Compose, K8s manifests, Helm charts, and AWS resources provisioned with Terraform.



## Technologies

- Containerized deployments using docker-compose, K8s, Helm
- Prometheus (metrics collection)
- Grafana (visualization)
- Node Exporter (system metrics)
- Python Flask (application metrics)

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

Access services:
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090 (requires port-forward if using K8s setup)

## Next Steps

- [ ] Create Helm chart for the Flask service
- [ ] Move the setup to a Cloud environment using Terraform

---

*This is an active learning project being developed to demonstrate DevOps and SRE practices.*