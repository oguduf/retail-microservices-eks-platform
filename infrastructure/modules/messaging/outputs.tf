output "event_bus_name" {
  description = "Custom EventBridge event bus name."
  value       = aws_cloudwatch_event_bus.retail.name
}

output "event_bus_arn" {
  description = "Custom EventBridge event bus ARN."
  value       = aws_cloudwatch_event_bus.retail.arn
}

output "inventory_queue_url" {
  description = "SQS URL consumed by the Inventory service."
  value       = aws_sqs_queue.inventory.id
}

output "inventory_queue_arn" {
  description = "SQS ARN consumed by the Inventory service."
  value       = aws_sqs_queue.inventory.arn
}

output "notification_queue_url" {
  description = "SQS URL consumed by the Notification service."
  value       = aws_sqs_queue.notification.id
}

output "notification_queue_arn" {
  description = "SQS ARN consumed by the Notification service."
  value       = aws_sqs_queue.notification.arn
}