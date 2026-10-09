variable "project_name" {
  description = "Project prefix used for the budget name."
  type        = string
}

variable "environment" {
  description = "Environment name used for the budget name."
  type        = string
}

variable "alert_email" {
  description = "Email address for AWS budget alerts; an empty value disables the budget."
  type        = string
}

variable "monthly_budget_limit" {
  description = "Monthly AWS cost alert threshold in USD."
  type        = number
}
