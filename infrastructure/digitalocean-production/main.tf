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

  backend "s3" {
    bucket                      = "formerr-spaces"
    key                         = "terraform/production/terraform.tfstate"
    region                      = "us-east-1"
    endpoints = {
      s3 = "https://formerr-spaces.nyc3.digitaloceanspaces.com"
    }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
  }

}

# Local variables
locals {
  environment = "production"
  cluster_name = "formerr-production"
  registry_name = "formerr-production-registry"
  
  common_tags = [
    "formerr",
    "production",
    "terraform"
  ]
}

# Configure providers
provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  host  = module.kubernetes_cluster.cluster_endpoint
  token = module.kubernetes_cluster.cluster_token
  cluster_ca_certificate = module.kubernetes_cluster.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host  = module.kubernetes_cluster.cluster_endpoint
    token = module.kubernetes_cluster.cluster_token
    cluster_ca_certificate = module.kubernetes_cluster.cluster_ca_certificate
  }
}

# Create VPC for isolation
resource "digitalocean_vpc" "production_vpc" {
  name     = "${local.cluster_name}-vpc"
  region   = var.region
  ip_range = "10.10.0.0/16"
}

# Kubernetes Cluster using our module
module "kubernetes_cluster" {
  source = "../modules/kubernetes-cluster"

  cluster_name       = local.cluster_name
  region            = var.region
  node_count        = var.node_count
  node_size         = var.node_size
  kubernetes_version = var.kubernetes_version
  ha                = true   # Production needs HA
  auto_upgrade      = false  # Manual upgrades in production
  surge_upgrade     = true
  tags             = local.common_tags

  maintenance_policy = {
    start_time = "03:00"  # 3 AM maintenance window
    day        = "sunday"
  }
}

# Container Registry using our module  
module "container_registry" {
  source = "../modules/container-registry"

  registry_name     = local.registry_name
  subscription_tier = "professional"  # Higher tier for production
  region           = var.region
  tags             = local.common_tags

  depends_on = [module.kubernetes_cluster]
}

# Load Balancer for ingress with SSL
resource "digitalocean_loadbalancer" "production_lb" {
  name     = "${local.cluster_name}-lb"
  region   = var.region
  vpc_uuid = digitalocean_vpc.production_vpc.id
  size     = "lb-medium"  # Larger LB for production

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

# Firewall for additional security
resource "digitalocean_firewall" "production_firewall" {
  name = "${local.cluster_name}-firewall"

  droplet_ids = []

  # Allow HTTP/HTTPS traffic
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow SSH (restrict to office IPs in real production)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]  # TODO: Restrict to office IPs
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
