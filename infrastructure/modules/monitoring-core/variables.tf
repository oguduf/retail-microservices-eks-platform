variable "project_name" {
  description = "Unique project prefix used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "alert_email" {
  description = "Optional email endpoint for monitoring alerts. The recipient must confirm the SNS subscription."
  type        = string
  default     = ""
}
