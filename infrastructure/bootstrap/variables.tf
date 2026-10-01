variable "aws_region" {
  description = "AWS Region where Terraform state resources are created."
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Unique project prefix used in resource names and tags."
  type        = string
  default     = "guduf-retail-eks"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state."
  type        = string
}