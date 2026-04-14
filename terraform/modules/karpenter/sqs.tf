################################################################################
# SQS Queue for Spot Interruption Handling
#
# Karpenter watches this queue for:
# - Spot interruption warnings (2 min notice)
# - Instance rebalance recommendations
# - Scheduled change events (maintenance)
# - Instance state changes (terminated)
#
# This gives Karpenter time to gracefully drain pods before node loss.
################################################################################

resource "aws_sqs_queue" "karpenter" {
  name                      = "${var.cluster_name}-karpenter"
  message_retention_seconds = 300 # 5 min — events are time-sensitive
  sqs_managed_sse_enabled   = true

  tags = local.common_tags
}

resource "aws_sqs_queue_policy" "karpenter" {
  queue_url = aws_sqs_queue.karpenter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EventBridgePublish"
        Effect = "Allow"
        Principal = {
          Service = ["events.amazonaws.com", "sqs.amazonaws.com"]
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.karpenter.arn
      },
    ]
  })
}