# Kubernetes Event Driven Monitoring on AWS

An event-driven monitoring project using a Kubernetes event producer, AWS Lambda, Amazon SQS, SNS, S3, DynamoDB, and API Gateway. Terraform manages AWS infrastructure; GitHub Actions deploys it using OIDC.

## Architecture

```text
Kubernetes event-producer Pod (EKS)
             |
             | IRSA-authenticated SendMessage
             v
        Amazon SQS queue -----> Dead-letter queue
             |
             v
      Event processor Lambda
        |       |       |
        v       v       v
   DynamoDB    S3      SNS (critical events)

Client --> API Gateway --> Query Lambda --> DynamoDB
```

## Application components

| Component | Responsibility |
|---|---|
| Kubernetes event producer | Sends sample health and service events to SQS using its dedicated IRSA role. |
| Event processor Lambda | Processes queued events, archives raw payloads in S3, stores searchable records in DynamoDB, and publishes critical alerts to SNS. |
| Query API Lambda | Reads event records from DynamoDB for API requests. |
| API Gateway HTTP API | Exposes read-only event query endpoints. |

SQS, SNS, S3, DynamoDB, API Gateway, and CloudWatch are managed AWS services supporting the application components.

## Existing AWS foundation

The project reuses the existing `us-east-2` VPC, EKS cluster, worker nodes, EKS OIDC provider, GitHub Actions OIDC role, ECR, and Terraform state bucket. Existing retail resources remain tracked in Terraform until a reviewed plan removes resources no longer needed by this project.

## Repository layout

```text
infrastructure/       Terraform bootstrap, modules, and dev environment
kubernetes/           Namespace and event-producer Kubernetes manifests
lambda/               Event processor and query API Lambda code
docs/                 Architecture, runbook, and demo evidence
.github/workflows/    Terraform and application deployment workflows
```

## Delivery flow

1. GitHub Actions authenticates to AWS using OIDC.
2. Terraform plans infrastructure changes against the existing S3 remote state.
3. CI tests and builds the event producer, then publishes its immutable image to ECR.
4. The platform workflow deploys the image to EKS.
5. Lambda functions process SQS messages and serve queries through API Gateway.

## Project status

- Existing VPC, EKS, ECR, data, cache, and messaging resources are tracked in Terraform.
- Terraform code has been consolidated into this repository and validated against the existing state.
- Event producer, processor Lambda, query API Lambda, and monitoring-specific AWS resources remain to be implemented.

## Cost notes

The existing NAT Gateway, EKS cluster and nodes, RDS instance, and Valkey cache can incur ongoing charges. The RDS and cache are not required by the target design. Remove unneeded resources through Terraform only after reviewing a plan that preserves the shared network and EKS resources.
