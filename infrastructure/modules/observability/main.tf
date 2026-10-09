resource "aws_cloudwatch_log_group" "eks_application" {
  for_each = toset(["application", "dataplane", "host", "performance", "agents"])

  name              = "/aws/containerinsights/${var.cluster_name}/${each.value}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "orders_database" {
  for_each = toset(["postgresql", "upgrade"])

  name              = "/aws/rds/instance/${var.orders_database_identifier}/${each.value}"
  retention_in_days = 14
}

resource "aws_cloudwatch_metric_alarm" "orders_database_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-retail-db-high-cpu"
  alarm_description   = "Retail RDS CPU has exceeded 80% for three consecutive five-minute periods."
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = 80
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.orders_database_identifier
  }

  alarm_actions = [var.critical_events_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "orders_database_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-retail-db-low-storage"
  alarm_description   = "Retail RDS has less than 2 GiB of free storage."
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Minimum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 2147483648
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.orders_database_identifier
  }

  alarm_actions = [var.critical_events_topic_arn]
}

resource "aws_cloudwatch_dashboard" "retail_platform" {
  dashboard_name = "${var.project_name}-${var.environment}-platform"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6,
        properties = {
          title = "EKS node CPU and memory utilization", view = "timeSeries", region = var.aws_region,
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", var.cluster_name],
            [".", "node_memory_utilization", ".", "."]
          ]
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6,
        properties = {
          title = "Retail RDS health", view = "timeSeries", region = var.aws_region,
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.orders_database_identifier],
            [".", "DatabaseConnections", ".", "."]
          ]
        }
      },
      {
        type = "metric", x = 0, y = 6, width = 24, height = 6,
        properties = {
          title = "Retail service pod CPU and memory", view = "timeSeries", region = var.aws_region,
          metrics = [
            ["ContainerInsights", "pod_cpu_utilization", "ClusterName", var.cluster_name, "Namespace", "coffee-store"],
            [".", "pod_memory_utilization", ".", ".", ".", "."]
          ]
        }
      }
    ]
  })
}
