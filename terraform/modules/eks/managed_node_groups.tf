################################################################################
# Managed Node Group — System Workloads
#
# IMPORTANT: This node group runs system-critical pods:
# - CoreDNS, kube-proxy
# - Karpenter controller (Karpenter can't provision its own nodes)
# - Argo CD controller
# - NGINX ingress controller
#
# We taint these nodes so application workloads land on Karpenter-managed nodes.
################################################################################

resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", # SSM for node debugging
  ])

  policy_arn = each.value
  role       = aws_iam_role.node.name
}

resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-system"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.system_node_instance_types

  scaling_config {
    desired_size = var.system_node_desired_size
    min_size     = var.system_node_min_size
    max_size     = var.system_node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  # Taint system nodes so only system pods (with tolerations) run here.
  # Application workloads go to Karpenter-managed nodes.
  taint {
    key    = "CriticalAddonsOnly"
    effect = "NO_SCHEDULE"
  }

  labels = {
    role = "system"
  }

  tags = merge(local.common_tags, {
    "karpenter.sh/discovery" = var.cluster_name
  })

  depends_on = [
    aws_iam_role_policy_attachment.node_policies,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}