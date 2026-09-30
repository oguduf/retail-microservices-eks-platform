# Retail Microservices Platform on AWS EKS

A four-service retail platform deployed to Amazon EKS using Terraform, Docker, Helm, and GitHub Actions.

## Architecture

```text
Internet
   |
Application Load Balancer / Kubernetes Ingress
   |
Amazon EKS
   ├── Product Service
   ├── Inventory Service
   ├── Order Service
   └── Notification Service
   |
AWS Data and Messaging Services
   ├── Amazon RDS for MySQL
   ├── Amazon DynamoDB
   ├── Amazon ElastiCache
   ├── Amazon EventBridge
   └── Amazon SQS with dead-letter queues
```

## Repositories

Replace `<YOUR-GITHUB-USERNAME>` with your GitHub username.

| Repository | Responsibility |
|---|---|
| [Infrastructure](https://github.com/oguduf/retail-infra-terraform) | Terraform for AWS networking, EKS, data, messaging, IAM, and observability |
| [Application](https://github.com/oguduf/retail-application) | Four microservices, tests, Dockerfiles, Docker Compose, and event contracts |
| [EKS Platform](https://github.com/oguduf/retail-eks-platform) | Helm charts, Kubernetes configuration, ingress, autoscaling, and deployments |

## Services

| Service | Responsibility | Primary Data Store |
|---|---|---|
| Product | Product catalog, categories, and pricing | MySQL |
| Inventory | Stock and reservation handling | DynamoDB |
| Order | Order creation and status updates | MySQL |
| Notification | Customer notifications | DynamoDB |

## Event Flow

1. Order Service publishes `OrderCreated`.
2. Inventory Service reserves or rejects stock.
3. Inventory Service publishes `InventoryReserved` or `InventoryFailed`.
4. Order Service updates the order status.
5. Notification Service consumes events and records notifications.

## Delivery Flow

1. Terraform provisions AWS infrastructure and ECR repositories.
2. Application CI tests, scans, builds, and pushes immutable images to ECR.
3. The EKS platform pipeline deploys images using Helm.
4. GitHub Actions validates, deploys, smoke-tests, and supports rollback.

## Project Status

Planning and repository structure complete. Infrastructure implementation is next.