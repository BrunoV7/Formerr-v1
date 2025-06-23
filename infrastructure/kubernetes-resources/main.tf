# Kubernetes Resources Configuration
# This file contains the Kubernetes resources that need to be created
# after the infrastructure is set up

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
  }
}

# Configure providers - these values should be passed as variables
variable "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  type        = string
}

variable "cluster_token" {
  description = "Kubernetes cluster token"
  type        = string
  sensitive   = true
}

variable "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  type        = string
  sensitive   = true
}

variable "registry_name" {
  description = "Container registry name"
  type        = string
}

variable "registry_docker_credentials" {
  description = "Registry docker credentials"
  type        = string
  sensitive   = true
}

provider "kubernetes" {
  host  = var.cluster_endpoint
  token = var.cluster_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

# Create namespace for monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }
}

# Create namespace for applications
resource "kubernetes_namespace" "apps" {
  metadata {
    name = "formerr"
    labels = {
      name = "formerr"
    }
  }
}

# Create registry secret for formerr namespace
resource "kubernetes_secret" "registry_secret" {
  metadata {
    name      = "${var.registry_name}-registry-secret"
    namespace = "formerr"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = var.registry_docker_credentials
  }

  depends_on = [kubernetes_namespace.apps]
}

# Create registry secret for monitoring namespace
resource "kubernetes_secret" "registry_secret_monitoring" {
  metadata {
    name      = "${var.registry_name}-registry-secret"
    namespace = "monitoring"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = var.registry_docker_credentials
  }

  depends_on = [kubernetes_namespace.monitoring]
}
