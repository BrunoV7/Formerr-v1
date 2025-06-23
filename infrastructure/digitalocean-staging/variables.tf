variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "node_count" {
  description = "Number of worker nodes in the cluster"
  type        = number
  default     = 2
}

variable "node_size" {
  description = "Size of the worker nodes"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29.1-do.0"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "use_existing_registry_secret" {
  description = "Whether to use an existing registry secret"
  type        = bool
  default     = false
}
