locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # /19 gives 8190 IPs per subnet — enough headroom for Karpenter scaling
  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 3, i)]
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 5, i + 8)]
  intra_subnets   = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 5, i + 12)]

  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "cava-k8s-platform"
  })
}