resource "aws_kms_key" "orders_database" {
  description             = "Encrypt the development Orders database and managed credentials"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_db_subnet_group" "orders" {
  name       = "${var.project_name}-${var.environment}-orders"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name       = "${var.project_name}-${var.environment}-orders"
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_db_parameter_group" "orders" {
  name   = "${var.project_name}-${var.environment}-orders-postgres16"
  family = "postgres16"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_min_duration_statement"
    value        = "1000"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_statement"
    value        = "ddl"
    apply_method = "pending-reboot"
  }

  tags = {
    Name       = "${var.project_name}-${var.environment}-orders-postgres16"
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_security_group" "orders_database" {
  name_prefix = "${var.project_name}-${var.environment}-orders-db-"
  description = "Permit PostgreSQL only from EKS worker nodes."
  vpc_id      = var.vpc_id
  egress      = []

  ingress {
    description     = "PostgreSQL from EKS managed node group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.cluster_security_group_id]
  }

  tags = {
    Name       = "${var.project_name}-${var.environment}-orders-db"
    Repository = "retail-microservices-eks-platform"
  }
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "orders_enhanced_monitoring" {
  name = "${var.project_name}-${var.environment}-orders-rds-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
        ArnEquals = {
          "aws:SourceArn" = "arn:${data.aws_partition.current.partition}:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:${var.project_name}-${var.environment}-orders"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "orders_enhanced_monitoring" {
  role       = aws_iam_role.orders_enhanced_monitoring.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "orders" {
  #checkov:skip=CKV_AWS_293:Deletion protection is off only for this disposable dev lab so the reviewed destroy workflow can clean up.
  #checkov:skip=CKV_AWS_353:Performance Insights is disabled in the lab to limit telemetry cost; CloudWatch metrics and logs remain enabled.
  #checkov:skip=CKV2_AWS_30:Only DDL and slow statements are logged to reduce sensitive SQL/PII exposure; do not log all SQL in the lab.
  identifier                          = "${var.project_name}-${var.environment}-orders"
  engine                              = "postgres"
  engine_version                      = "16.14"
  instance_class                      = var.orders_db_instance_class
  allocated_storage                   = 20
  max_allocated_storage               = 50
  storage_type                        = "gp3"
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.orders_database.arn
  db_name                             = "orders"
  username                            = "orders_admin"
  manage_master_user_password         = true
  master_user_secret_kms_key_id       = aws_kms_key.orders_database.arn
  iam_database_authentication_enabled = true
  parameter_group_name                = aws_db_parameter_group.orders.name
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  db_subnet_group_name                = aws_db_subnet_group.orders.name
  vpc_security_group_ids              = [aws_security_group.orders_database.id]
  publicly_accessible                 = false
  multi_az                            = var.orders_db_multi_az
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.orders_enhanced_monitoring.arn
  backup_retention_period             = 7
  auto_minor_version_upgrade          = true
  deletion_protection                 = false
  skip_final_snapshot                 = true
  copy_tags_to_snapshot               = true
  performance_insights_enabled        = false

  tags = {
    Name       = "${var.project_name}-${var.environment}-orders"
    Repository = "retail-microservices-eks-platform"
  }

  depends_on = [aws_iam_role_policy_attachment.orders_enhanced_monitoring]
}
