output "kubernetes_cluster_name" {
  value       = google_container_cluster.monitoring_cluster.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.monitoring_cluster.endpoint
  description = "GKE Cluster Host"
  sensitive   = true
}

output "region" {
  value       = var.gcp_region
  description = "GCP Region"
}

output "project_id" {
  value       = var.gcp_project_id
  description = "GCP Project ID"
}

output "grafana_access" {
  value       = "kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
  description = "Command to access Grafana"
}

output "configure_kubectl" {
  value       = "gcloud container clusters get-credentials ${google_container_cluster.monitoring_cluster.name} --region ${var.gcp_region} --project ${var.gcp_project_id}"
  description = "Command to configure kubectl"
}