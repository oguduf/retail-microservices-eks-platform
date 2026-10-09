variable "project_name" {
  description = "Project prefix used for database resource names."
  type        = string
}

variable "environment" {
  description = "Environment name used for database resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC where the database security group is created."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets used by the RDS subnet group."
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group permitted to reach PostgreSQL."
  type        = string
}

variable "orders_db_instance_class" {
  description = "Instance class for the Orders PostgreSQL database."
  type        = string
}

variable "orders_db_multi_az" {
  description = "Whether the Orders database has a synchronous standby."
  type        = bool
}
