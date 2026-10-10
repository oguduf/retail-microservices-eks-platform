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

output "cloudtrail_name" {
  description = "Name of the account-level CloudTrail management-events trail."
  value       = module.cloudtrail.trail_name
}

output "cloudtrail_log_bucket_name" {
  description = "Name of the S3 bucket receiving CloudTrail logs."
  value       = module.cloudtrail.log_bucket_name
}

output "orders_database_endpoint" {
  description = "Private DNS endpoint for the Orders PostgreSQL database."
  value       = module.database.address
}

output "orders_database_secret_arn" {
  description = "Secrets Manager ARN for RDS-managed Orders database credentials."
  value       = module.database.master_user_secret_arn
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

output "event_bus_name" {
  description = "Custom EventBridge event bus name."
  value       = module.messaging.event_bus_name
}

output "notification_queue_url" {
  description = "SQS URL consumed by the Notification service."
  value       = module.messaging.notification_queue_url
}

output "notification_dlq_url" {
  description = "SQS dead-letter queue URL for failed order notifications."
  value       = module.messaging.notification_dlq_url
}

output "order_notifications_topic_arn" {
  description = "SNS topic ARN used for customer order notifications."
  value       = module.messaging.order_notifications_topic_arn
}

output "order_event_publisher_role_arn" {
  description = "IRSA role ARN used by the order service to publish order events."
  value       = module.messaging.order_event_publisher_role_arn
}

output "karpenter_controller_role_arn" {
  description = "IRSA role ARN used by the Karpenter controller."
  value       = module.eks.karpenter_controller_role_arn
}

output "karpenter_node_role_name" {
  description = "EC2 node role name used by Karpenter-provisioned nodes."
  value       = module.eks.karpenter_node_role_name
}

output "order_db_migrator_role_arn" {
  description = "IRSA role used only by the one-shot Orders database bootstrap Job."
  value       = module.messaging.order_database_migrator_role_arn
}

output "inventory_service_role_arn" {
  description = "IRSA role ARN used by Inventory to connect to PostgreSQL as inventory_app."
  value       = module.messaging.inventory_service_role_arn
}

output "notification_consumer_role_arn" {
  description = "IRSA role ARN used by the notification service to consume and publish notifications."
  value       = module.messaging.notification_consumer_role_arn
}

output "load_balancer_controller_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller."
  value       = module.eks.load_balancer_controller_role_arn
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
