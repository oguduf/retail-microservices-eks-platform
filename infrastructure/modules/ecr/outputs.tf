output "repository_urls" {
  description = "ECR repository URLs keyed by microservice name."
  value = {
    for service, repository in aws_ecr_repository.service :
    service => repository.repository_url
  }
}