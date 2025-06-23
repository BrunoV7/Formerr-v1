locals {
  registry = var.use_existing ? data.digitalocean_container_registry.existing[0] : digitalocean_container_registry.registry[0]
}

output "registry_id" {
  description = "ID of the container registry"
  value       = local.registry.id
}

output "registry_name" {
  description = "Name of the container registry"
  value       = local.registry.name
}

output "registry_endpoint" {
  description = "Endpoint URL of the container registry"
  value       = local.registry.endpoint
}

output "registry_server_url" {
  description = "Server URL of the container registry"
  value       = local.registry.server_url
}

output "docker_credentials" {
  description = "Docker credentials for the registry"
  value       = digitalocean_container_registry_docker_credentials.registry_credentials.docker_credentials
  sensitive   = true
}

output "registry_secret_name" {
  description = "Name of the Kubernetes registry secret"
  value       = "${local.registry.name}-registry-secret"  # Static value since secret will be created separately
}
