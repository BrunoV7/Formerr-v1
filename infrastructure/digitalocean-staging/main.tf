terraform {
  required_version = ">= 1.6"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }

  # Remote state backend - configurar depois
  # backend "s3" {
  #   endpoint                    = "nyc3.digitaloceanspaces.com"
  #   key                        = "terraform/staging/terraform.tfstate"
  #   bucket                     = "formerr-terraform-state"
  #   region                     = "us-east-1"
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  # }
}

# Local variables
locals {
  environment = "staging"
  cluster_name = "formerr-staging"
  registry_name = "formerr-staging-registry"
  
  common_tags = [
    "formerr",
    "staging",
    "terraform"
  ]
}

# Configure providers
provider "digitalocean" {
  token = var.do_token
}

# Kubernetes and Helm providers will be configured dynamically
# when the cluster is available

# Create VPC for isolation
resource "digitalocean_vpc" "staging_vpc" {
  name     = "${local.cluster_name}-vpc"
  region   = var.region
  ip_range = "10.20.0.0/16"
}

# Kubernetes Cluster using our module
module "kubernetes_cluster" {
  source = "../modules/kubernetes-cluster"

  cluster_name       = local.cluster_name
  region            = var.region
  node_count        = var.node_count
  node_size         = var.node_size
  kubernetes_version = var.kubernetes_version
  ha                = false  # Staging doesn't need HA
  auto_upgrade      = true
  surge_upgrade     = true
  tags             = local.common_tags

  maintenance_policy = {
    start_time = "02:00"  # 2 AM maintenance window
    day        = "sunday"
  }
}

# Container Registry using our module  
module "container_registry" {
  source = "../modules/container-registry"

  registry_name     = local.registry_name
  subscription_tier = "basic"
  region           = var.region
  tags             = local.common_tags

  depends_on = [module.kubernetes_cluster]
}

# Load Balancer for ingress
resource "digitalocean_loadbalancer" "staging_lb" {
  name     = "${local.cluster_name}-lb"
  region   = var.region
  vpc_uuid = digitalocean_vpc.staging_vpc.id
  size     = "lb-small"

  forwarding_rule {
    entry_protocol  = "http"
    entry_port      = 80
    target_protocol = "http"
    target_port     = 80
  }

  forwarding_rule {
    entry_protocol  = "https"
    entry_port      = 443
    target_protocol = "http"
    target_port     = 80
    tls_passthrough = false
  }

  healthcheck {
    protocol               = "http"
    port                   = 80
    path                   = "/health"
    check_interval_seconds = 10
    response_timeout_seconds = 5
    unhealthy_threshold    = 3
    healthy_threshold      = 2
  }

  depends_on = [module.kubernetes_cluster]
}
