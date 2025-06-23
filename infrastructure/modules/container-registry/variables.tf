variable "registry_name" {
  description = "Name of the container registry"
  type        = string
}

variable "subscription_tier" {
  description = "Subscription tier for the registry"
  type        = string
  default     = "basic"
  validation {
    condition     = contains(["starter", "basic", "professional"], var.subscription_tier)
    error_message = "Subscription tier must be one of: starter, basic, professional."
  }
}

variable "region" {
  description = "Region for the container registry"
  type        = string
  default     = "nyc3"
}

variable "tags" {
  description = "Tags to apply to the registry"
  type        = list(string)
  default     = []
}

variable "use_existing" {
  description = "Whether to use existing registry instead of creating new one"
  type        = bool
  default     = true
}
