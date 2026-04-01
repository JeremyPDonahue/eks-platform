################################################################################
# EKS Cluster Security Group
################################################################################

resource "aws_security_group" "cluster_additional" {
  name_prefix = "${var.cluster_name}-cluster-additional"
  description = "Additional security group rules for EKS cluster"
  vpc_id      = var.vpc_id

  # Allow nodes to communicate with control plane
  ingress {
    description = "Node to control plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-cluster-additional-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
