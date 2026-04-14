################################################################################
# Locals
################################################################################

locals {
  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "cava-k8s-platform"
  })
}