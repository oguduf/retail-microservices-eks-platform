variable "project_name" {
  description = "Project prefix used for CloudWatch resource names."
  type        = string
}

variable "environment" {
  description = "Environment name used for CloudWatch resource names."
  type        = string
}

variable "aws_region" {
  description = "AWS Region used by the CloudWatch dashboard."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name used by Container Insights log groups and metrics."
  type        = string
}

variable "orders_database_identifier" {
  description = "RDS identifier used by log groups, alarms, and dashboard widgets."
  type        = string
}

variable "critical_events_topic_arn" {
  description = "SNS topic that receives critical RDS alarm notifications."
  type        = string
}
