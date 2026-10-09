provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "retail-microservices-eks-platform"
    }
  }
}

provider "aws" {
  alias  = "billing"
  region = "us-east-1"
}
