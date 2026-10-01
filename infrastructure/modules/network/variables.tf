variable "project_name" {
  description = "Unique project prefix used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones for the VPC subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR ranges for private subnets."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Whether to use one NAT gateway for the lab environment."
  type        = bool
  default     = true
}