variable "aws_region" {
  description = "AWS Region for the development environment."
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

variable "vpc_cidr" {
  description = "CIDR range for the retail EKS VPC."
  type        = string
  default     = "10.50.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the development VPC."
  type        = list(string)
  default = [
    "us-east-2a",
    "us-east-2b"
  ]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR ranges for load balancers and NAT gateway."
  type        = list(string)
  default = [
    "10.50.0.0/24",
    "10.50.1.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR ranges for EKS, databases, and caches."
  type        = list(string)
  default = [
    "10.50.10.0/24",
    "10.50.11.0/24"
  ]
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string
  default     = "guduf-retail-eks-dev"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
  default     = "1.36"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS managed node groups."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 4
}