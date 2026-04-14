variable "cluster_name" {
  type = string
}

variable "cluster_oidc_issuer_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

locals {
  oidc_issuer = replace(var.cluster_oidc_issuer_url, "https://", "")

  common_tags = merge(var.tags, {
    ManagedBy = "terraform"
    Project   = "cava-k8s-platform"
  })
}