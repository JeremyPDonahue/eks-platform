# SUBNET CONFIGURATION
data "aws_availability_zones" "available" {
  state = "available"

  # Exclude local zones — they don't support EKS
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index)
  tags = {
    Name                                        = "${var.cluster_name}-private-${count.index}"
    Cluster                                     = var.cluster_name
    Environment                                 = var.environment
    ManagedBy                                   = "terraform"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
  }

}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.this.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 12)
  map_public_ip_on_launch = true
  tags = {
    Name                                        = "${var.cluster_name}-public-${count.index}"
    Cluster                                     = var.cluster_name
    Environment                                 = var.environment
    ManagedBy                                   = "terraform"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

}
