# IRSA (IAM Roles for Service Accounts) Module

### Creates least-privilege IAM roles for Kubernetes workloads using OIDC federation. Each role is scoped to a specific ServiceAccount.

# IRSA vs Node IAM:
 - Node IAM: every pod on a node gets the same permissions (overly broad)
 - IRSA: per-pod IAM roles via projected service account tokens (least privilege)
