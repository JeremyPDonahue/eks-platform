output "karpenter_controller_role_arn" {
  description = "IAM role ARN for Karpenter controller (used in Helm values)"
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_queue_name" {
  description = "SQS queue name for Karpenter interruption handling"
  value       = aws_sqs_queue.karpenter.name
}