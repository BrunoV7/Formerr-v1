output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = module.kubernetes_cluster.cluster_id
}

output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = module.kubernetes_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes cluster"
  value       = module.kubernetes_cluster.cluster_endpoint
}

output "registry_endpoint" {
  description = "Container registry endpoint"
  value       = module.container_registry.registry_endpoint
}

output "registry_name" {
  description = "Container registry name"
  value       = module.container_registry.registry_name
}

output "loadbalancer_ip" {
  description = "Load balancer IP address"
  value       = digitalocean_loadbalancer.production_lb.ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = local.vpc_id
}

output "kubeconfig" {
  description = "Kubeconfig for the cluster"
  value       = module.kubernetes_cluster.kubeconfig
  sensitive   = true
}

output "monitoring_namespace" {
  description = "Monitoring namespace"
  value       = module.kubernetes_cluster.monitoring_namespace
}

output "apps_namespace" {
  description = "Applications namespace"
  value       = module.kubernetes_cluster.apps_namespace
}

output "firewall_id" {
  description = "Firewall ID"
  value       = digitalocean_firewall.production_firewall.id
}

output "cluster_token" {
  description = "Token for the Kubernetes cluster"
  value       = module.kubernetes_cluster.cluster_token
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate for the Kubernetes cluster"
  value       = module.kubernetes_cluster.cluster_ca_certificate
  sensitive   = true
}

output "registry_docker_credentials" {
  description = "Docker credentials for the registry"
  value       = module.container_registry.docker_credentials
  sensitive   = true
}
