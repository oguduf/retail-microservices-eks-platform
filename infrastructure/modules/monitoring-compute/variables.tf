variable "project_name" {
  description = "Unique project prefix used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "events_queue_arn" {
  description = "ARN of the SQS queue that invokes the event processor."
  type        = string
}

variable "events_table_name" {
  description = "Name of the DynamoDB monitoring events table."
  type        = string
}

variable "events_table_arn" {
  description = "ARN of the DynamoDB monitoring events table."
  type        = string
}

variable "event_archive_bucket_name" {
  description = "Name of the private S3 archive bucket."
  type        = string
}

variable "event_archive_bucket_arn" {
  description = "ARN of the private S3 archive bucket."
  type        = string
}

variable "critical_events_topic_arn" {
  description = "ARN of the SNS topic for critical monitoring events."
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider used for IRSA."
  type        = string
}

variable "eks_oidc_issuer_url" {
  description = "EKS OIDC issuer URL used for IRSA trust conditions."
  type        = string
}
