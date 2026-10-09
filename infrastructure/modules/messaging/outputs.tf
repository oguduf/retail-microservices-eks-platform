output "event_bus_name" {
  description = "Custom EventBridge event bus name."
  value       = aws_cloudwatch_event_bus.retail.name
}

output "event_bus_arn" {
  description = "Custom EventBridge event bus ARN."
  value       = aws_cloudwatch_event_bus.retail.arn
}

output "notification_queue_url" {
  description = "SQS URL consumed by the Notification service."
  value       = aws_sqs_queue.notification.id
}

output "notification_queue_arn" {
  description = "SQS ARN consumed by the Notification service."
  value       = aws_sqs_queue.notification.arn
}

output "notification_dlq_url" {
  description = "SQS URL for failed order-notification messages."
  value       = aws_sqs_queue.notification_dlq.id
}

output "order_notifications_topic_arn" {
  description = "SNS topic ARN published to by the order-notification consumer."
  value       = aws_sns_topic.order_notifications.arn
}

output "order_event_publisher_role_arn" {
  description = "IRSA role ARN for the order service to publish to EventBridge."
  value       = aws_iam_role.order_event_publisher.arn
}

output "order_database_migrator_role_arn" {
  description = "IRSA role for the one-shot Orders database schema/bootstrap job."
  value       = aws_iam_role.order_database_migrator.arn
}

output "inventory_service_role_arn" {
  description = "IRSA role ARN for the Inventory service's least-privilege RDS IAM user."
  value       = aws_iam_role.inventory_service.arn
}

output "notification_consumer_role_arn" {
  description = "IRSA role ARN for the notification service to consume SQS and publish SNS."
  value       = aws_iam_role.notification_consumer.arn
}
