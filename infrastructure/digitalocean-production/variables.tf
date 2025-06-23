variable "do_token" {
  description = "DigitalOcean Personal Access Token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc3"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "formerr-production"
}

variable "cluster_version" {
  description = "Kubernetes cluster version"
  type        = string
  default     = "1.32.5-do.0"
}

variable "node_count" {
  description = "Number of worker nodes in the cluster"
  type        = number
  default     = 2
}

variable "node_size" {
  description = "Size of the worker nodes"
  type        = string
  default     = "s-2vcpu-2gb"
}

variable "use_existing_vpc" {
  description = "Whether to use an existing VPC instead of creating a new one"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name of the existing VPC to use"
  type        = string
  default     = "formerr-production-vpc"
}

variable "registry_name" {
  description = "Name of the container registry"
  type        = string
  default     = "formerr"
}

variable "use_existing_registry" {
  description = "Whether to use an existing container registry"
  type        = bool
  default     = true
}

variable "registry_tier" {
  description = "Container registry subscription tier"
  type        = string
  default     = "basic"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "formerr"
    ManagedBy   = "terraform"
  }
}
