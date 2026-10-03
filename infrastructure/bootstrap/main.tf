resource "aws_s3_bucket" "terraform_state" {
  #checkov:skip=CKV_AWS_145:SSE-S3 is used for this development state backend; a customer-managed key is not required for this lab.
  #checkov:skip=CKV_AWS_19:Encryption is configured by aws_s3_bucket_server_side_encryption_configuration.terraform_state below.
  #checkov:skip=CKV_AWS_21:Versioning is configured by aws_s3_bucket_versioning.terraform_state below.
  #checkov:skip=CKV_AWS_18:Access logging is configured by aws_s3_bucket_logging.terraform_state below.
  #checkov:skip=CKV_AWS_144:Cross-region replication is not configured for this single-region development backend.
  bucket = var.state_bucket_name
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state_access_logs" {
  #checkov:skip=CKV_AWS_18:This is the access log destination; logging it would create a recursive delivery chain.
  #checkov:skip=CKV_AWS_19:Encryption is configured by aws_s3_bucket_server_side_encryption_configuration.terraform_state_access_logs below.
  #checkov:skip=CKV_AWS_21:Versioning is configured by aws_s3_bucket_versioning.terraform_state_access_logs below.
  #checkov:skip=CKV_AWS_145:S3 server access log delivery requires SSE-S3 rather than SSE-KMS.
  #checkov:skip=CKV_AWS_144:Cross-region replication is not configured for this single-region development log sink.
  bucket = "${var.state_bucket_name}-access-logs"
}

resource "aws_s3_bucket_public_access_block" "terraform_state_access_logs" {
  bucket = aws_s3_bucket.terraform_state_access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "terraform_state_access_logs" {
  bucket = aws_s3_bucket.terraform_state_access_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_access_logs" {
  bucket = aws_s3_bucket.terraform_state_access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_access_logs" {
  bucket = aws_s3_bucket.terraform_state_access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_access_logs" {
  bucket = aws_s3_bucket.terraform_state_access_logs.id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

data "aws_iam_policy_document" "terraform_state_access_logs" {
  statement {
    sid    = "AllowS3ServerAccessLogDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.terraform_state_access_logs.arn}/terraform-state/*"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.terraform_state.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state_access_logs" {
  bucket = aws_s3_bucket.terraform_state_access_logs.id
  policy = data.aws_iam_policy_document.terraform_state_access_logs.json
}

resource "aws_s3_bucket_logging" "terraform_state" {
  bucket        = aws_s3_bucket.terraform_state.id
  target_bucket = aws_s3_bucket.terraform_state_access_logs.id
  target_prefix = "terraform-state/"

  depends_on = [aws_s3_bucket_policy.terraform_state_access_logs]
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
