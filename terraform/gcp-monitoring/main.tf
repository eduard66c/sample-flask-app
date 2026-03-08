# VPC Network
resource "google_compute_network" "monitoring_vpc" {
  name                    = "monitoring-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "monitoring_subnet" {
  name          = "monitoring-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.monitoring_vpc.id
}

# GKE Cluster
resource "google_container_cluster" "monitoring_cluster" {
  name     = var.cluster_name
  location = var.gcp_region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.monitoring_vpc.name
  subnetwork = google_compute_subnetwork.monitoring_subnet.name

  # We can't use the default cluster logging for our example cluster
  logging_service = "logging.googleapis.com/kubernetes"

  deletion_protection = false
}

# Separately Managed Node Pool
resource "google_container_node_pool" "monitoring_nodes" {
  name       = "monitoring-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.monitoring_cluster.name
  node_count = var.node_count

  node_config {
    preemptible  = false
    machine_type = var.machine_type

    disk_size_gb = 50
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env       = "monitoring"
      terraform = "true"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Kubernetes Namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }

  depends_on = [google_container_node_pool.monitoring_nodes]
}

# Deploy Prometheus Stack
resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "57.0.0"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false

  values = [
    file("${path.module}/helm/values-prometheus.yaml")
  ]

  depends_on = [google_container_node_pool.monitoring_nodes]
}

# Deploy Loki Stack
resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  version          = "2.10.0"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false

  values = [
    file("${path.module}/helm/values-loki.yaml")
  ]

  depends_on = [google_container_node_pool.monitoring_nodes]
}

# Deploy Flask App
resource "helm_release" "flask_app" {
  name             = "flask-app"
  chart            = "${path.module}/helm/flask-app"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false

  values = [
    file("${path.module}/helm/flask-app/values.yaml")
  ]

  depends_on = [helm_release.loki]
}