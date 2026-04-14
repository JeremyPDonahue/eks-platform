################################################################################
# EKS Cluster
################################################################################

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true # Lock down with public_access_cidrs in production

    security_group_ids = [aws_security_group.cluster_additional.id]
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  # Control plane logging — audit + api for security; scheduler + controller-manager
  # for debugging scheduling issues (important for Karpenter troubleshooting)
  enabled_cluster_log_types = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policies,
  ]
}