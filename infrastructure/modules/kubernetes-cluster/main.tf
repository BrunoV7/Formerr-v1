terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
  }
}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name     = var.cluster_name
  region   = var.region
  version  = var.kubernetes_version
  ha       = var.ha
  tags     = var.tags

  auto_upgrade      = var.auto_upgrade
  surge_upgrade     = var.surge_upgrade

  maintenance_policy {
    start_time = var.maintenance_policy.start_time
    day        = var.maintenance_policy.day
  }

  node_pool {
    name       = "${var.cluster_name}-nodes"
    size       = var.node_size
    node_count = var.node_count
    tags       = var.tags

    auto_scale = true
    min_nodes  = var.node_count
    max_nodes  = var.node_count * 2
  }
}

# Create namespace for monitoring
resource "kubernetes_namespace" "monitoring" {
  depends_on = [digitalocean_kubernetes_cluster.cluster]
  
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
      environment = var.cluster_name
    }
  }
}

# Create namespace for applications
resource "kubernetes_namespace" "apps" {
  depends_on = [digitalocean_kubernetes_cluster.cluster]
  
  metadata {
    name = "formerr"
    labels = {
      name = "formerr"
      environment = var.cluster_name
    }
  }
}
