# VPC Module for EKS

## Design decisions:
- 3 AZ for HA (EKS control plane requirement for production)
- Private subnets for worker nodes (no public IPs on nodes)
- Public subnets only for NLB/ALB ingress
- Separate intra subnets for EKS control plane ENIs
- Single NAT GW for cost optimization in pilot; upgrade to per-AZ for prod
- DNS hostnames enabled (required for EKS node registration)
- Subnet tagging for Karpenter discovery + LB controller

