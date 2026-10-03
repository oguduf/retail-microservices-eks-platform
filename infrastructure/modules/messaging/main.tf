locals {
  eks_oidc_issuer = replace(var.eks_oidc_issuer_url, "https://", "")
}

data "aws_kms_alias" "sns" {
  name = "alias/aws/sns"
}

resource "aws_cloudwatch_event_bus" "retail" {
  name = "${var.project_name}-${var.environment}-events"
}

resource "aws_sqs_queue" "notification_dlq" {
  #checkov:skip=CKV_AWS_27:SSE-SQS is enabled below; Checkov 2.0.930 does not recognize SQS-managed encryption.
  name                      = "${var.project_name}-${var.environment}-notification-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue" "notification" {
  #checkov:skip=CKV_AWS_27:SSE-SQS is enabled below; Checkov 2.0.930 does not recognize SQS-managed encryption.
  name                       = "${var.project_name}-${var.environment}-notification"
  visibility_timeout_seconds = 60
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notification_dlq.arn
    maxReceiveCount     = 5
  })
}

resource "aws_cloudwatch_event_rule" "order_created" {
  name           = "${var.project_name}-${var.environment}-order-created"
  event_bus_name = aws_cloudwatch_event_bus.retail.name

  event_pattern = jsonencode({
    source        = ["retail.orders"]
    "detail-type" = ["OrderCreated"]
  })
}

resource "aws_cloudwatch_event_target" "order_created_notification" {
  rule           = aws_cloudwatch_event_rule.order_created.name
  event_bus_name = aws_cloudwatch_event_bus.retail.name
  target_id      = "notification-queue"
  arn            = aws_sqs_queue.notification.arn

  dead_letter_config {
    arn = aws_sqs_queue.notification_dlq.arn
  }
}

resource "aws_sqs_queue_policy" "notification_eventbridge" {
  queue_url = aws_sqs_queue.notification.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgeOrderCreated"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.notification.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.order_created.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "notification_dlq_eventbridge" {
  queue_url = aws_sqs_queue.notification_dlq.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowEventBridgeFailedDeliveries"
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.notification_dlq.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_cloudwatch_event_rule.order_created.arn
        }
      }
    }]
  })
}

data "aws_iam_policy_document" "order_event_publisher_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:sub"
      values   = ["system:serviceaccount:coffee-store:order-service"]
    }
  }
}

resource "aws_iam_role" "order_event_publisher" {
  name               = "${var.project_name}-${var.environment}-order-event-publisher-role"
  assume_role_policy = data.aws_iam_policy_document.order_event_publisher_assume_role.json
}

resource "aws_iam_role_policy" "order_event_publisher" {
  name = "${var.project_name}-${var.environment}-order-event-publisher-policy"
  role = aws_iam_role.order_event_publisher.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "PublishOrderCreatedEvents"
      Effect   = "Allow"
      Action   = "events:PutEvents"
      Resource = aws_cloudwatch_event_bus.retail.arn
    }]
  })
}

resource "aws_iam_role" "notification_consumer" {
  name = "${var.project_name}-${var.environment}-notification-consumer-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.eks_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.eks_oidc_issuer}:aud" = "sts.amazonaws.com"
          "${local.eks_oidc_issuer}:sub" = "system:serviceaccount:coffee-store:notification-service"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "notification_consumer" {
  name = "${var.project_name}-${var.environment}-notification-consumer-policy"
  role = aws_iam_role.notification_consumer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ConsumeOrderNotifications"
        Effect = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage"
        ]
        Resource = aws_sqs_queue.notification.arn
      },
      {
        Sid      = "PublishOrderNotifications"
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.order_notifications.arn
      },
      {
        Sid    = "UseSnsManagedEncryptionKey"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = data.aws_kms_alias.sns.target_key_arn
      }
    ]
  })
}

resource "aws_sns_topic" "order_notifications" {
  name              = "${var.project_name}-${var.environment}-order-notifications"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "order_notifications_email" {
  count     = var.order_notification_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.order_notifications.arn
  protocol  = "email"
  endpoint  = var.order_notification_email
}

resource "aws_cloudwatch_metric_alarm" "notification_dlq_messages" {
  alarm_name          = "${var.project_name}-${var.environment}-order-notification-dlq-not-empty"
  alarm_description   = "One or more order notifications reached the dead-letter queue and need investigation."
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.notification_dlq.name
  }

  alarm_actions = [var.operations_alert_topic_arn]
}
