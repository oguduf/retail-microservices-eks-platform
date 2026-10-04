variable "project_name" {
  description = "Unique project prefix used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN used to trust the order and notification service accounts."
  type        = string
}

variable "eks_oidc_issuer_url" {
  description = "EKS OIDC issuer URL used to scope IRSA trust to the service accounts."
  type        = string
}

variable "order_notification_email" {
  description = "Optional email recipient for order notifications. The recipient must confirm the SNS subscription."
  type        = string
  default     = ""
}

variable "operations_alert_topic_arn" {
  description = "SNS topic ARN for operational alerts when order notifications enter the DLQ."
  type        = string
}
