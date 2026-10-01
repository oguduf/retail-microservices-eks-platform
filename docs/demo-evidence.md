# Demo Evidence

This document will contain screenshots and verification evidence for the Retail Microservices Platform on AWS EKS.

## Repository and CI/CD Evidence

- GitHub Project board showing planned and completed work
- GitHub Actions workflow runs for infrastructure, application, and EKS platform repositories
- Pull requests from `dev` into `main`
- Successful Terraform validation and plan
- Successful container image build and security scan

## AWS Infrastructure Evidence

- Terraform apply output
- VPC with public and private subnets across multiple Availability Zones
- Amazon EKS cluster and managed node group
- Amazon ECR repositories for all four services
- RDS MySQL instance
- DynamoDB tables
- ElastiCache cluster
- EventBridge event bus and rules
- SQS queues and dead-letter queues

## EKS Worker-Node Launch Template

- Terraform replaced the managed node group with a launch-template-based node group.
- The launch template applies a `Name` tag to worker EC2 instances.
- Verification: replacement node group became Active and EC2 instances displayed the expected `Name` tag.

## Kubernetes Evidence

- EKS worker nodes registered and ready
- Kubernetes namespace for the application
- Helm release status
- Product, Inventory, Order, and Notification deployments
- Running pods and container logs
- Kubernetes services and ingress
- Readiness and liveness probes
- Horizontal Pod Autoscaler configuration

## Application Evidence

- Product catalog request succeeds
- Inventory reservation succeeds or fails correctly
- New order is created
- Order status changes after inventory processing
- Notification is created from an event
- End-to-end order workflow succeeds

## Observability and Failure Testing

- CloudWatch logs for each service
- CloudWatch alarms and dashboard
- Failed message appears in a dead-letter queue
- Recovery or replay of a failed message
- Failed deployment and Helm rollback evidence
