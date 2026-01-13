# Monitoring Stack with Docker Compose

**Status:** Work in Progress 🚧

A production-style observability stack using Prometheus, Grafana, and Docker Compose. This project demonstrates infrastructure-as-code principles and modern monitoring practices.

## Current Status

- ✅ Docker Compose configuration with Prometheus, Grafana, Node Exporter
- ✅ Basic Prometheus scraping configuration
- ✅ Custom Flask application with metrics
- 🚧 Grafana dashboard configuration (in progress)
- 🚧 Comprehensive documentation (in progress)

## Technologies

- Docker & Docker Compose
- Prometheus (metrics collection)
- Grafana (visualization)
- Node Exporter (system metrics)
- Python Flask (application metrics)

## Quick Start
```bash
docker-compose up -d
```

Access services:
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090

## Next Steps

- [ ] Add instrumented Flask application
- [ ] Create custom Grafana dashboards
- [ ] Add alerting rules
- [ ] Complete documentation

---

*This is an active learning project being developed to demonstrate DevOps and SRE practices.*