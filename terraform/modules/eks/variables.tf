################################################################################
# EKS Cluster Module
#
# Design decisions:
# - EKS 1.29+ with API server endpoint private + public (public for CI/CD,
#   lock down with CIDR restriction in production)
# - Managed node group for system workloads (CoreDNS, kube-proxy, Karpenter
#   controller itself). Karpenter can't schedule its own controller.
# - IRSA (IAM Roles for Service Accounts) over node-level IAM — least privilege
# - EKS managed addons for vpc-cni, coredns, kube-proxy — auto-patched
# - Secrets encryption with KMS
# - Control plane logging to CloudWatch (audit + API for security visibility)
################################################################################

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "Subnets for worker nodes"
  type        = list(string)
}

variable "intra_subnet_ids" {
  description = "Subnets for EKS control plane ENIs"
  type        = list(string)
}

variable "environment" {
  type    = string
  default = "nonprod"
}

variable "system_node_instance_types" {
  description = "Instance types for the system managed node group"
  type        = list(string)
  default     = ["m6i.large", "m6a.large", "m5.large"]
}

variable "system_node_desired_size" {
  type    = number
  default = 2
}

variable "system_node_min_size" {
  type    = number
  default = 2
}

variable "system_node_max_size" {
  type    = number
  default = 5
}

variable "tags" {
  type    = map(string)
  default = {}
}