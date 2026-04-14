# Karpenter Module — IAM + Infrastructure

## Karpenter needs:
1. IRSA role to manage EC2 instances, pricing API, SSM, SQS
2. SQS queue for spot interruption + node termination handling
3. EventBridge rules to forward EC2 events to the SQS queue

### The actual NodePool + EC2NodeClass are Kubernetes manifests — see kubernetes/karpenter/ directory. This module handles the AWS-side setup.

## Why Karpenter over Cluster Autoscaler:
- Karpenter provisions right-sized nodes (no pre-defined node groups)
- Faster scaling: direct EC2 fleet API vs ASG
- Native spot interruption handling
- Consolidation: automatically replaces underutilized nodes
- Better for heterogeneous workloads (varying CPU/memory ratios)
