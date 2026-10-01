resource "aws_cloudwatch_event_bus" "retail" {
  name = "${var.project_name}-${var.environment}-events"
}

resource "aws_sqs_queue" "inventory_dlq" {
  name                      = "${var.project_name}-${var.environment}-inventory-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue" "notification_dlq" {
  name                      = "${var.project_name}-${var.environment}-notification-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue" "inventory" {
  name                       = "${var.project_name}-${var.environment}-inventory"
  visibility_timeout_seconds = 60
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.inventory_dlq.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "notification" {
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

resource "aws_cloudwatch_event_target" "order_created_inventory" {
  rule           = aws_cloudwatch_event_rule.order_created.name
  event_bus_name = aws_cloudwatch_event_bus.retail.name
  target_id      = "inventory-queue"
  arn            = aws_sqs_queue.inventory.arn
}

resource "aws_cloudwatch_event_target" "order_created_notification" {
  rule           = aws_cloudwatch_event_rule.order_created.name
  event_bus_name = aws_cloudwatch_event_bus.retail.name
  target_id      = "notification-queue"
  arn            = aws_sqs_queue.notification.arn
}

resource "aws_sqs_queue_policy" "inventory_eventbridge" {
  queue_url = aws_sqs_queue.inventory.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowEventBridgeOrderCreated"
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.inventory.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_cloudwatch_event_rule.order_created.arn
        }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "notification_eventbridge" {
  queue_url = aws_sqs_queue.notification.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
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
    }]
  })
}