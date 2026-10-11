data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  trail_name  = "${var.project_name}-${var.environment}"
  bucket_name = "${var.project_name}-${var.environment}-cloudtrail-${data.aws_caller_identity.current.account_id}"
  trail_arn   = "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.trail_name}"
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  #checkov:skip=CKV_AWS_18:Server access logging is omitted for this cost-conscious development audit bucket; production should send access logs to a separate protected log archive.
  #checkov:skip=CKV_AWS_21:Versioning is enabled by aws_s3_bucket_versioning.cloudtrail_logs below; Checkov 2.0.930 does not correlate the separate resource.
  #checkov:skip=CKV_AWS_144:Cross-region replication is omitted for this single-region development log archive to avoid duplicate storage and replication charges; production audit retention should use a centralized replicated archive.
  #checkov:skip=CKV_AWS_19:KMS encryption is enabled by aws_s3_bucket_server_side_encryption_configuration.cloudtrail_logs below; Checkov 2.0.930 does not correlate the separate resource.
  #checkov:skip=CKV_AWS_145:Customer-managed KMS encryption is enabled by aws_s3_bucket_server_side_encryption_configuration.cloudtrail_logs below; Checkov 2.0.930 does not correlate the separate resource.
  bucket        = local.bucket_name
  force_destroy = false

  tags = {
    Name      = local.bucket_name
    Purpose   = "CloudTrail audit logs"
    Retention = "90-days"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.cloudtrail_logs.arn
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "cloudtrail_logs" {
  description             = "Encrypt ${local.trail_name} CloudTrail log files"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableAccountIAMPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudTrailToEncryptTrailLogs"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = ["kms:GenerateDataKey*", "kms:DescribeKey"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = local.trail_arn
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${local.trail_name}-cloudtrail-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    id     = "expire-cloudtrail-logs-after-90-days"
    status = "Enabled"

    filter {}

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.cloudtrail_logs.arn
        Condition = {
          StringEquals = {
            "aws:SourceArn" = local.trail_arn
          }
        }
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control"
            "aws:SourceArn" = local.trail_arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.cloudtrail_logs]
}

resource "aws_cloudtrail" "account_management_events" {
  #checkov:skip=CKV2_AWS_10:CloudTrail delivers the audit archive to S3; CloudWatch Logs duplication is omitted in this development account to control ingestion and storage costs.
  name                          = local.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  kms_key_id                    = aws_kms_key.cloudtrail_logs.arn
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  # Capture account management activity only. Data events are intentionally
  # excluded to keep this development audit trail cost-conscious.
  event_selector {
    include_management_events = true
    read_write_type           = "All"
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_logs,
    aws_s3_bucket_server_side_encryption_configuration.cloudtrail_logs,
    aws_s3_bucket_ownership_controls.cloudtrail_logs,
    aws_s3_bucket_versioning.cloudtrail_logs,
    aws_s3_bucket_lifecycle_configuration.cloudtrail_logs,
  ]

  tags = {
    Name        = local.trail_name
    Purpose     = "Account management event audit trail"
    Project     = var.project_name
    Environment = var.environment
  }
}
