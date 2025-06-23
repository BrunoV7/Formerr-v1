variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc3"  # Different region from staging
}

variable "node_count" {
  description = "Number of worker nodes in the cluster"
  type        = number
  default     = 3  # More nodes for production
}

variable "node_size" {
  description = "Size of the worker nodes"
  type        = string
  default     = "s-4vcpu-8gb"  # Larger nodes for production
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29.1-do.0"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
