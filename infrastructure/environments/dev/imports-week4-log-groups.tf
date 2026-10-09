import {
  to = module.observability.aws_cloudwatch_log_group.eks_application["dataplane"]
  id = "/aws/containerinsights/guduf-retail-eks-dev/dataplane"
}

import {
  to = module.observability.aws_cloudwatch_log_group.eks_application["performance"]
  id = "/aws/containerinsights/guduf-retail-eks-dev/performance"
}

import {
  to = module.observability.aws_cloudwatch_log_group.eks_application["application"]
  id = "/aws/containerinsights/guduf-retail-eks-dev/application"
}

import {
  to = module.observability.aws_cloudwatch_log_group.eks_application["host"]
  id = "/aws/containerinsights/guduf-retail-eks-dev/host"
}

import {
  to = module.observability.aws_cloudwatch_log_group.orders_database["postgresql"]
  id = "/aws/rds/instance/guduf-retail-eks-dev-orders/postgresql"
}
