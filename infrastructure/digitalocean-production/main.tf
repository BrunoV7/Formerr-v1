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

  # Commented out S3 backend - using local backend for now
  # backend "s3" {
  #   bucket                      = "formerr-spaces"
  #   key                         = "terraform/production/terraform.tfstate"
  #   region                      = "us-east-1"
  #   endpoints = {
  #     s3 = "https://formerr-spaces.nyc3.digitaloceanspaces.com"
  #   }
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  # }

}

# Local variables
locals {
  environment = "production"
  cluster_name = "formerr-production"
  registry_name = "formerr"  # Use o registry existente
  
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

# Kubernetes and Helm providers will be configured dynamically
# when the cluster is available

# VPC - Use existing or create new
data "digitalocean_vpc" "existing_vpc" {
  count = var.use_existing_vpc ? 1 : 0
  name  = var.vpc_name
}

resource "digitalocean_vpc" "production_vpc" {
  count    = var.use_existing_vpc ? 0 : 1
  name     = var.vpc_name
  region   = var.region
  ip_range = "10.10.0.0/16"
}

locals {
  vpc_id = var.use_existing_vpc ? data.digitalocean_vpc.existing_vpc[0].id : digitalocean_vpc.production_vpc[0].id
}

# Kubernetes Cluster using our module
module "kubernetes_cluster" {
  source = "../modules/kubernetes-cluster"

  cluster_name       = local.cluster_name
  region            = var.region
  node_count        = var.node_count
  node_size         = var.node_size
  kubernetes_version = var.cluster_version
  ha                = false  # Disabled due to droplet limit (3 max)
  auto_upgrade      = false  # Manual upgrades in production
  surge_upgrade     = true
  tags             = local.common_tags
  vpc_uuid          = local.vpc_id

  maintenance_policy = {
    start_time = "03:00"  # 3 AM maintenance window
    day        = "sunday"
  }
}

# Container Registry using our module  
module "container_registry" {
  source = "../modules/container-registry"

  registry_name     = "formerr"  # Use o registry existente
  use_existing      = true       # Use o registry existente
  subscription_tier = "basic"    # Mudado para basic para baixo custo
  region           = var.region
  tags             = local.common_tags

  # Removido depends_on para não depender do cluster
}

# Load Balancer for ingress (optional)
resource "digitalocean_loadbalancer" "production_lb" {
  count    = var.create_load_balancer ? 1 : 0
  name     = "${local.cluster_name}-lb"
  region   = var.region
  vpc_uuid = local.vpc_id
  size     = "lb-small"  # Changed to small for cost optimization

  forwarding_rule {
    entry_protocol  = "http"
    entry_port      = 80
    target_protocol = "http"
    target_port     = 80
  }

  # HTTPS rule only if enabled and certificate is available
  dynamic "forwarding_rule" {
    for_each = var.enable_https ? [1] : []
    content {
      entry_protocol  = "https"
      entry_port      = 443
      target_protocol = "http"
      target_port     = 80
      tls_passthrough = true  # Use TLS passthrough to avoid certificate requirement
    }
  }

  healthcheck {
    protocol               = "http"
    port                   = 80
    path                   = "/"  # Changed from /health to / as it's more common
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
