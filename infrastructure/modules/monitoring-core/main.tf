data "aws_caller_identity" "current" {}

resource "aws_sqs_queue" "events_dlq" {
  name                      = "${var.project_name}-${var.environment}-monitoring-events-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_sqs_queue" "events" {
  name                       = "${var.project_name}-${var.environment}-monitoring-events"
  visibility_timeout_seconds = 180
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.events_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_dynamodb_table" "events" {
  name         = "${var.project_name}-${var.environment}-monitoring-events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "eventId"

  attribute {
    name = "eventId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_s3_bucket" "event_archive" {
  bucket = "${var.project_name}-${var.environment}-monitoring-events-${data.aws_caller_identity.current.account_id}"

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_s3_bucket_public_access_block" "event_archive" {
  bucket = aws_s3_bucket.event_archive.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "event_archive" {
  bucket = aws_s3_bucket.event_archive.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "event_archive" {
  bucket = aws_s3_bucket.event_archive.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "event_archive" {
  bucket = aws_s3_bucket.event_archive.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "event_archive" {
  bucket = aws_s3_bucket.event_archive.id

  rule {
    id     = "expire-lab-event-archives"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

resource "aws_sns_topic" "critical_events" {
  name              = "${var.project_name}-${var.environment}-monitoring-critical-events"
  kms_master_key_id = "alias/aws/sns"

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_sns_topic_subscription" "critical_events_email" {
  count     = var.alert_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.critical_events.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "event_processor_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-event-processor-errors"
  alarm_description   = "The monitoring event processor Lambda reported one or more errors."
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "${var.project_name}-${var.environment}-event-processor"
  }

  alarm_actions = [aws_sns_topic.critical_events.arn]

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_cloudwatch_metric_alarm" "event_query_api_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-event-query-api-errors"
  alarm_description   = "The monitoring event query API Lambda reported one or more errors."
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "${var.project_name}-${var.environment}-event-query-api"
  }

  alarm_actions = [aws_sns_topic.critical_events.arn]

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_cloudwatch_metric_alarm" "events_dlq_messages" {
  alarm_name          = "${var.project_name}-${var.environment}-monitoring-dlq-not-empty"
  alarm_description   = "One or more monitoring events reached the dead-letter queue and need investigation."
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.events_dlq.name
  }

  alarm_actions = [aws_sns_topic.critical_events.arn]

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}
