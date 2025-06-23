output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.cluster.id
}

output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.cluster.endpoint
}

output "cluster_token" {
  description = "Token for the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate for the Kubernetes cluster"
  value       = base64decode(digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig for the cluster"
  value       = digitalocean_kubernetes_cluster.cluster.kube_config[0].raw_config
  sensitive   = true
}

output "cluster_urn" {
  description = "URN of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.cluster.urn
}

output "node_pool" {
  description = "Node pool information"
  value = {
    id         = digitalocean_kubernetes_cluster.cluster.node_pool[0].id
    name       = digitalocean_kubernetes_cluster.cluster.node_pool[0].name
    size       = digitalocean_kubernetes_cluster.cluster.node_pool[0].size
    node_count = digitalocean_kubernetes_cluster.cluster.node_pool[0].node_count
  }
}

output "monitoring_namespace" {
  description = "Monitoring namespace name"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "apps_namespace" {
  description = "Applications namespace name"
  value       = kubernetes_namespace.apps.metadata[0].name
}
