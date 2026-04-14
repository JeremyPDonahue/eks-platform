locals {
  oidc_issuer = replace(var.cluster_oidc_issuer_url, "https://", "")

  common_tags = merge(var.tags, {
    ManagedBy = "terraform"
    Project   = "cava-k8s-platform"
  })
}