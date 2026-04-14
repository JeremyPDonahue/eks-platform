variable "cluster_name" {
  description = "EKS cluster name — used for subnet tagging"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "single_nat_gateway" {
  description = "Use single NAT gateway (cost savings for pilot). Set false for HA in production."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}