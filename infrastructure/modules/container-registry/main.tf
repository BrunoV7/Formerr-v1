terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
  }
}

resource "digitalocean_container_registry" "registry" {
  name                   = var.registry_name
  subscription_tier_slug = var.subscription_tier
  region                 = var.region
}

# Container registry docker credentials for Kubernetes
resource "digitalocean_container_registry_docker_credentials" "registry_credentials" {
  registry_name = digitalocean_container_registry.registry.name
}

# Note: Kubernetes secrets will be created separately after cluster is ready
# This avoids provider dependency issues during initial infrastructure setup

# # Create a Kubernetes secret for registry authentication
# resource "kubernetes_secret" "registry_secret" {
#   metadata {
#     name      = "${var.registry_name}-registry-secret"
#     namespace = "formerr"
#   }

#   type = "kubernetes.io/dockerconfigjson"

#   data = {
#     ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.registry_credentials.docker_credentials
#   }

#   depends_on = [digitalocean_container_registry_docker_credentials.registry_credentials]
# }

# # Create registry secret for monitoring namespace too
# resource "kubernetes_secret" "registry_secret_monitoring" {
#   metadata {
#     name      = "${var.registry_name}-registry-secret"
#     namespace = "monitoring"
#   }

#   type = "kubernetes.io/dockerconfigjson"

#   data = {
#     ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.registry_credentials.docker_credentials
#   }

#   depends_on = [digitalocean_container_registry_docker_credentials.registry_credentials]
# }
