variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS is created."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS control plane and worker nodes."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired worker-node count."
  type        = number
}

variable "node_min_size" {
  description = "Minimum worker-node count."
  type        = number
}

variable "node_max_size" {
  description = "Maximum worker-node count."
  type        = number
}