# Terraform variables for DigitalOcean Production
# Configured for account with 3 droplet limit

# Region must match VPC region
region = "nyc3"

# Minimal cluster configuration due to droplet limits
node_count = 1
node_size = "s-2vcpu-2gb"

# Use existing resources
use_existing_vpc = true
vpc_name = "formerr-production-vpc"
use_existing_registry = true
registry_name = "formerr"
registry_tier = "basic"

# Cluster configuration
cluster_name = "formerr-production"
cluster_version = "1.32.5-do.0"

# Load balancer (disabled by default due to certificate requirements)
create_load_balancer = false
enable_https = false

environment = "production"
