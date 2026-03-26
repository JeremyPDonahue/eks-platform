variable "cluster_name" {
    type = string
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "environment" {
    type = string
    default = "development"
}

resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      Name = "${var.cluster_name}-vpc"
      Cluster = var.cluster_name
      Environment = var.environment
      ManagedBy = "terraform"
    }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
    count = 3
    vpc_id = aws_vpc.this.id
    availability_zone = data.aws_availability_zones.available.names[count.index]  
    cidr_block = cidrsubnet(var.vpc_cidr, 3, count.index)    
    tags = {
      Name = "${var.cluster_name}-private-${count.index}"
      Cluster = var.cluster_name
      Environment = var.environment
      ManagedBy = "terraform"
      "kubernetes.io/role/internal-elb"           = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      "karpenter.sh/discovery"                    = var.cluster_name
    }

}

resource "aws_subnet" "public" {
    count = 3
    vpc_id = aws_vpc.this.id
    availability_zone = data.aws_availability_zones.available.names[count.index]  
    cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 12)
    map_public_ip_on_launch = true 
    tags = {
      Name = "${var.cluster_name}-public-${count.index}"
      Cluster = var.cluster_name
      Environment = var.environment
      ManagedBy = "terraform"
      "kubernetes.io/role/elb"                    = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }

}