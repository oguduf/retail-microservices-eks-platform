variable "project_name" {
  description = "Unique project prefix used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "service_names" {
  description = "Names of containerized retail microservices."
  type        = set(string)
}