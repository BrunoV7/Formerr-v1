output "registry_id" {
  description = "ID of the container registry"
  value       = digitalocean_container_registry.registry.id
}

output "registry_name" {
  description = "Name of the container registry"
  value       = digitalocean_container_registry.registry.name
}

output "registry_endpoint" {
  description = "Endpoint URL of the container registry"
  value       = digitalocean_container_registry.registry.endpoint
}

output "registry_server_url" {
  description = "Server URL of the container registry"
  value       = digitalocean_container_registry.registry.server_url
}

output "docker_credentials" {
  description = "Docker credentials for the registry"
  value       = digitalocean_container_registry_docker_credentials.registry_credentials.docker_credentials
  sensitive   = true
}

output "registry_secret_name" {
  description = "Name of the Kubernetes registry secret"
  value       = kubernetes_secret.registry_secret.metadata[0].name
}
