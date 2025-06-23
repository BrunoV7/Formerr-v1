terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
  }
}

# Try to use existing registry first
data "digitalocean_container_registry" "existing" {
  count = var.use_existing ? 1 : 0
  name  = var.registry_name
}

resource "digitalocean_container_registry" "registry" {
  count                  = var.use_existing ? 0 : 1
  name                   = var.registry_name
  subscription_tier_slug = "basic"  # Mudado para "basic" que é mais barato
  region                 = var.region
}

locals {
  registry_name = var.use_existing ? data.digitalocean_container_registry.existing[0].name : digitalocean_container_registry.registry[0].name
}

# Container registry docker credentials for Kubernetes
resource "digitalocean_container_registry_docker_credentials" "registry_credentials" {
  registry_name = local.registry_name
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
