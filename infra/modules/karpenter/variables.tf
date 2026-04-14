variable "cluster_name" {
  type = string
}

variable "cluster_oidc_issuer_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "node_role_arn" {
  description = "ARN of the node IAM role (from EKS module)"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}