data "aws_caller_identity" "cloudwatch_logs" {}

data "aws_partition" "cloudwatch_logs" {}

data "aws_region" "cloudwatch_logs" {}

resource "aws_kms_key" "cloudwatch_logs" {
  description             = "Encrypt EKS and orders database CloudWatch log groups"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableAccountIAMPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.cloudwatch_logs.partition}:iam::${data.aws_caller_identity.cloudwatch_logs.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsForManagedLogGroups"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.cloudwatch_logs.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*",
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = [
              "arn:${data.aws_partition.cloudwatch_logs.partition}:logs:${data.aws_region.cloudwatch_logs.name}:${data.aws_caller_identity.cloudwatch_logs.account_id}:log-group:/aws/containerinsights/${var.cluster_name}/*",
              "arn:${data.aws_partition.cloudwatch_logs.partition}:logs:${data.aws_region.cloudwatch_logs.name}:${data.aws_caller_identity.cloudwatch_logs.account_id}:log-group:/aws/rds/instance/${var.orders_database_identifier}/*",
            ]
          }
        }
      },
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-observability-logs"
  }
}
