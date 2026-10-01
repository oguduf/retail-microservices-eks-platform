module "network" {
  source = "../../modules/network"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  single_nat_gateway = true
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  service_names = toset([
    "product",
    "inventory",
    "order",
    "notification",
    "frontend",
    "monitoring-event-producer"
  ])
}

module "data" {
  source = "../../modules/data"

  project_name                  = var.project_name
  environment                   = var.environment
  vpc_id                        = module.network.vpc_id
  private_subnet_ids            = module.network.private_subnet_ids
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
}

module "messaging" {
  source = "../../modules/messaging"

  project_name               = var.project_name
  environment                = var.environment
  eks_oidc_provider_arn      = module.eks.oidc_provider_arn
  eks_oidc_issuer_url        = module.eks.cluster_oidc_issuer_url
  order_notification_email   = var.order_notification_email
  operations_alert_topic_arn = module.monitoring_core.critical_events_topic_arn
}

module "cache" {
  source = "../../modules/cache"

  project_name                  = var.project_name
  environment                   = var.environment
  vpc_id                        = module.network.vpc_id
  private_subnet_ids            = module.network.private_subnet_ids
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
}

module "monitoring_core" {
  source = "../../modules/monitoring-core"

  project_name = var.project_name
  environment  = var.environment
  alert_email  = var.monitoring_alert_email
}

module "monitoring_compute" {
  source = "../../modules/monitoring-compute"

  project_name              = var.project_name
  environment               = var.environment
  events_queue_arn          = module.monitoring_core.events_queue_arn
  events_table_name         = module.monitoring_core.events_table_name
  events_table_arn          = module.monitoring_core.events_table_arn
  event_archive_bucket_name = module.monitoring_core.event_archive_bucket_name
  event_archive_bucket_arn  = module.monitoring_core.event_archive_bucket_arn
  critical_events_topic_arn = module.monitoring_core.critical_events_topic_arn
  eks_oidc_provider_arn     = module.eks.oidc_provider_arn
  eks_oidc_issuer_url       = module.eks.cluster_oidc_issuer_url
}
