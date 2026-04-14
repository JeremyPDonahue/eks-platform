################################################################################
# CAVA Kubernetes Platform — Production Environment
#
# Root module that composes all infrastructure modules.
# Designed for Terraform Cloud workspace: cava-k8s-platform-prod
#
# Usage:
#   terraform init
#   terraform plan -out=plan.tfplan
#   terraform apply plan.tfplan
################################################################################

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Terraform Cloud backend — align with their requirement for TFC experience
  cloud {
    organization = "cava-group"

    workspaces {
      name = "cava-k8s-platform-prod"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "cava-k8s-platform"
      Environment = "prod"
      ManagedBy   = "terraform"
      Team        = "platform-engineering"
    }
  }
}

################################################################################
# Variables
################################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cava-platform-prod"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source = "../../modules/vpc"

  cluster_name       = var.cluster_name
  vpc_cidr           = var.vpc_cidr
  environment        = var.environment
  single_nat_gateway = true # Pilot phase — upgrade for HA

  tags = {
    Phase = "pilot"
  }
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  intra_subnet_ids   = module.vpc.intra_subnet_ids
  environment        = var.environment

  # System node sizing: m6i.large = 2 vCPU, 8 GiB
  # Enough for CoreDNS, Karpenter, Argo CD, NGINX, monitoring
  system_node_instance_types = ["m6i.large", "m6a.large", "m5.large"]
  system_node_desired_size   = 2
  system_node_min_size       = 2
  system_node_max_size       = 5
}

################################################################################
# Karpenter
################################################################################

module "karpenter" {
  source = "../../modules/karpenter"

  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn
  node_role_arn           = module.eks.node_role_arn
}

################################################################################
# IRSA Roles
################################################################################

module "iam" {
  source = "../../modules/iam"

  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn
}

################################################################################
# Outputs — used by Kubernetes manifests and CI/CD
################################################################################

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "configure_kubectl" {
  description = "Configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "karpenter_controller_role_arn" {
  value = module.karpenter.karpenter_controller_role_arn
}

output "karpenter_queue_name" {
  value = module.karpenter.karpenter_queue_name
}

output "grafana_role_arn" {
  value = module.iam.grafana_role_arn
}
