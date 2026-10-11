output "trail_name" {
  description = "Name of the account-level multi-Region CloudTrail management-events trail."
  value       = aws_cloudtrail.account_management_events.name
}

output "log_bucket_name" {
  description = "Private S3 bucket receiving CloudTrail logs, with 90-day lifecycle expiration."
  value       = aws_s3_bucket.cloudtrail_logs.id
}
