# Demo Evidence

Capture evidence as each project phase is completed.

## Repository and CI/CD

- Terraform migration PR and successful no-change plan against the existing remote state
- Successful GitHub Actions OIDC authentication
- Successful Terraform plan/apply for monitoring resources
- Successful producer test, image build, and ECR push

## Shared AWS foundation

- Existing VPC and EKS cluster reused
- EKS worker nodes Ready
- Dedicated IRSA role for the event-producer service account

## Event pipeline

- Producer Pod sends a sample event to SQS
- Processor Lambda invocation and CloudWatch logs
- Event record appears in DynamoDB
- Raw event object appears in the private S3 archive bucket
- Critical event generates an SNS email notification
- Failed event is retained in the SQS dead-letter queue

## Query API

- API Gateway routes for `GET /events` and `GET /events/{eventId}`
- Successful response for an existing event and expected response for a missing event

## Operations and cost

- CloudWatch alarms for Lambda errors and DLQ message count
- Evidence of a failed message and recovery procedure
- Final Terraform plan or cleanup evidence for lab resources
