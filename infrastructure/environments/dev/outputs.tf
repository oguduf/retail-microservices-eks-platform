output "vpc_id" {
  description = "Development VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "nat_gateway_id" {
  description = "Single NAT gateway ID."
  value       = module.network.nat_gateway_id
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_issuer_url" {
  description = "OIDC issuer URL for Kubernetes workload IAM roles."
  value       = module.eks.cluster_oidc_issuer_url
}

output "eks_node_group_name" {
  description = "Default EKS managed node group."
  value       = module.eks.node_group_name
}

output "eks_oidc_provider_arn" {
  description = "IAM OIDC provider ARN for EKS workload identity."
  value       = module.eks.oidc_provider_arn
}

output "ecr_repository_urls" {
  description = "ECR repository URLs keyed by retail microservice name."
  value       = module.ecr.repository_urls
}

output "eks_cluster_security_group_id" {
  description = "Security group ID used by the EKS cluster."
  value       = module.eks.cluster_security_group_id
}

output "mysql_endpoint" {
  description = "Private MySQL endpoint for Product and Order services."
  value       = module.data.mysql_endpoint
}

output "mysql_master_secret_arn" {
  description = "Secrets Manager ARN holding RDS master credentials."
  value       = module.data.mysql_master_secret_arn
}

output "inventory_table_name" {
  description = "DynamoDB inventory table name."
  value       = module.data.inventory_table_name
}

output "notification_table_name" {
  description = "DynamoDB notification table name."
  value       = module.data.notification_table_name
}

output "event_bus_name" {
  description = "Custom EventBridge event bus name."
  value       = module.messaging.event_bus_name
}

output "inventory_queue_url" {
  description = "SQS URL consumed by the Inventory service."
  value       = module.messaging.inventory_queue_url
}

output "notification_queue_url" {
  description = "SQS URL consumed by the Notification service."
  value       = module.messaging.notification_queue_url
}

output "cache_primary_endpoint" {
  description = "Private Valkey cache endpoint."
  value       = module.cache.primary_endpoint_address
}

output "load_balancer_controller_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller."
  value       = module.eks.load_balancer_controller_role_arn
}

output "ebs_csi_driver_role_arn" {
  description = "IAM role used by the EBS CSI driver add-on through IRSA."
  value       = module.eks.ebs_csi_driver_role_arn
}

output "monitoring_events_queue_url" {
  description = "SQS queue URL used by the Kubernetes event producer."
  value       = module.monitoring_core.events_queue_url
}

output "monitoring_events_dlq_url" {
  description = "SQS dead-letter queue URL for failed monitoring events."
  value       = module.monitoring_core.events_dlq_url
}

output "monitoring_events_table_name" {
  description = "DynamoDB table used by the monitoring event processor."
  value       = module.monitoring_core.events_table_name
}

output "monitoring_event_archive_bucket_name" {
  description = "Private S3 bucket storing raw monitoring event payloads."
  value       = module.monitoring_core.event_archive_bucket_name
}

output "monitoring_critical_events_topic_arn" {
  description = "SNS topic ARN for critical event notifications."
  value       = module.monitoring_core.critical_events_topic_arn
}

output "monitoring_event_processor_function_name" {
  description = "Lambda function that processes monitoring events from SQS."
  value       = module.monitoring_compute.event_processor_function_name
}

output "monitoring_event_query_api_function_name" {
  description = "Lambda function serving monitoring event queries."
  value       = module.monitoring_compute.event_query_api_function_name
}

output "monitoring_events_api_endpoint" {
  description = "Base HTTPS endpoint for the monitoring event query API."
  value       = module.monitoring_compute.events_api_endpoint
}

output "monitoring_event_producer_role_arn" {
  description = "IRSA role ARN used by the Kubernetes event producer."
  value       = module.monitoring_compute.event_producer_role_arn
}
