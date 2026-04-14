resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true # Required for EKS node registration
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-vpc"
  })
}