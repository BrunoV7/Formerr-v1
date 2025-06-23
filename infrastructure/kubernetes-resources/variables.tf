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
