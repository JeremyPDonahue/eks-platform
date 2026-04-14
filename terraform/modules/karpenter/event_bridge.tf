################################################################################
# EventBridge Rules — Forward EC2 Events to SQS
################################################################################

# Spot interruption warning
resource "aws_cloudwatch_event_rule" "spot_interruption" {
  name        = "${var.cluster_name}-karpenter-spot-interruption"
  description = "Forward EC2 spot interruption warnings to Karpenter"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Spot Instance Interruption Warning"]
  })

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "spot_interruption" {
  rule      = aws_cloudwatch_event_rule.spot_interruption.name
  target_id = "karpenter"
  arn       = aws_sqs_queue.karpenter.arn
}

# Instance rebalance recommendation
resource "aws_cloudwatch_event_rule" "rebalance" {
  name        = "${var.cluster_name}-karpenter-rebalance"
  description = "Forward EC2 rebalance recommendations to Karpenter"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance Rebalance Recommendation"]
  })

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "rebalance" {
  rule      = aws_cloudwatch_event_rule.rebalance.name
  target_id = "karpenter"
  arn       = aws_sqs_queue.karpenter.arn
}

# Instance state change (catch terminated instances)
resource "aws_cloudwatch_event_rule" "state_change" {
  name        = "${var.cluster_name}-karpenter-state-change"
  description = "Forward EC2 state changes to Karpenter"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
  })

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "state_change" {
  rule      = aws_cloudwatch_event_rule.state_change.name
  target_id = "karpenter"
  arn       = aws_sqs_queue.karpenter.arn
}

# Scheduled changes (AWS maintenance events)
resource "aws_cloudwatch_event_rule" "scheduled_change" {
  name        = "${var.cluster_name}-karpenter-scheduled-change"
  description = "Forward AWS Health scheduled changes to Karpenter"

  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
  })

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "scheduled_change" {
  rule      = aws_cloudwatch_event_rule.scheduled_change.name
  target_id = "karpenter"
  arn       = aws_sqs_queue.karpenter.arn
}