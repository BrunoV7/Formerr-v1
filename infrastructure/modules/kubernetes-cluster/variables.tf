# Kubernetes Cluster Module
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 2
}

variable "node_size" {
  description = "Size of the nodes"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29.1-do.0"
}

variable "auto_upgrade" {
  description = "Enable auto-upgrade for the cluster"
  type        = bool
  default     = true
}

variable "surge_upgrade" {
  description = "Enable surge upgrade"
  type        = bool
  default     = true
}

variable "ha" {
  description = "Enable high availability"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = []
}

variable "maintenance_policy" {
  description = "Maintenance policy for the cluster"
  type = object({
    start_time = string
    day        = string
  })
  default = {
    start_time = "04:00"
    day        = "sunday"
  }
}
