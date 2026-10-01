output "events_queue_url" {
  description = "URL of the queue receiving monitoring events."
  value       = aws_sqs_queue.events.id
}

output "events_queue_arn" {
  description = "ARN of the queue receiving monitoring events."
  value       = aws_sqs_queue.events.arn
}

output "events_dlq_url" {
  description = "URL of the monitoring event dead-letter queue."
  value       = aws_sqs_queue.events_dlq.id
}

output "events_table_name" {
  description = "DynamoDB table storing processed monitoring events."
  value       = aws_dynamodb_table.events.name
}

output "events_table_arn" {
  description = "ARN of the DynamoDB monitoring events table."
  value       = aws_dynamodb_table.events.arn
}

output "event_archive_bucket_name" {
  description = "Private S3 bucket storing raw monitoring event payloads."
  value       = aws_s3_bucket.event_archive.bucket
}

output "event_archive_bucket_arn" {
  description = "ARN of the private S3 event archive bucket."
  value       = aws_s3_bucket.event_archive.arn
}

output "critical_events_topic_arn" {
  description = "SNS topic ARN for critical monitoring event alerts."
  value       = aws_sns_topic.critical_events.arn
}
