# Architecture

## Event flow

```text
Kubernetes event-producer Pod
  | sends JSON event using IRSA
  v
Amazon SQS queue --> Event processor Lambda
                         |       |       |
                         v       v       v
                     DynamoDB    S3      SNS for critical events

Client --> API Gateway HTTP API --> Query API Lambda --> DynamoDB

Browser --> public ALB --> Coffee Store frontend (EKS)
                              |--> Product Catalog service
                              |--> Inventory service (encrypted EBS-backed SQLite)
                              |--> Order service (encrypted EBS-backed SQLite)
                              `--> Notification service (encrypted EBS-backed SQLite)
```

The Coffee Store is deployed separately from the monitoring event producer. Its current app implementation keeps SQLite for inventory, orders, and notification records; EKS uses the EBS CSI add-on and encrypted gp3 persistent volumes for the development deployment. The notification service currently receives a best-effort HTTP call from the order service. The monitoring SQS/SNS pipeline is a separate system and is not yet the Coffee Store notification transport.

## Components and responsibilities

- The event producer runs in EKS and sends operational events to SQS. It has permission only to send messages to its queue.
- SQS buffers events and invokes the processor Lambda. A dead-letter queue retains messages that fail repeated processing.
- The processor Lambda validates each message, stores the raw event in S3, writes queryable event attributes to DynamoDB, and publishes critical events to SNS.
- The query API Lambda reads event records. API Gateway exposes `GET /events` and `GET /events/{eventId}`.
- CloudWatch collects logs and alarms on processor/API errors and messages accumulating in the dead-letter queue.

## Existing infrastructure reuse

Reuse the existing VPC, EKS cluster, worker nodes, EKS OIDC provider, GitHub OIDC role, ECR service, and Terraform S3 state bucket. Create monitoring-specific queues, tables, archive bucket, topic, Lambda functions, and API Gateway resources.

The existing RDS MySQL instance, Valkey cache, retail EventBridge bus, and retail-specific queues/tables are not part of this design. Keep them tracked until a Terraform plan can safely remove them without replacing the shared network or EKS cluster.

## Identity and security

- EKS event producer uses a dedicated Kubernetes service account and IRSA role scoped to `sqs:SendMessage` on its queue.
- Processor Lambda uses a dedicated role scoped to its queue, archive bucket prefix, DynamoDB table, and SNS topic.
- Query Lambda has read-only access to the event table.
- The archive bucket blocks public access, enables encryption, and uses lifecycle retention appropriate for the lab.
- CloudWatch alarms publish processor errors and a non-empty monitoring DLQ to the critical SNS topic. Email delivery is optional and requires a confirmed SNS email subscription.
- API Gateway exposes only the query operations needed for the demo. Authentication can be added if public access is not acceptable.

## Lab tradeoffs

One EKS cluster and the existing two worker nodes are reused. The design uses one queue and one dead-letter queue to keep the pipeline understandable. Production would add stricter API authentication, retention and recovery objectives, idempotency controls, multi-account separation, and centralized alert routing.
