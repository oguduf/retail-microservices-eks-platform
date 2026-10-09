# Stateful Services Database Migration and Cost Plan

## Migration objective

Move AWS Orders, Inventory, and Notifications from SQLite/EBS persistence to one private Multi-AZ RDS PostgreSQL instance, with separate schemas and database users for each service. The standby demonstrates managed database failover, at a higher cost than Single-AZ; Aurora's cluster architecture is not needed for this lab. Keep local Docker Compose on SQLite so developers can run the app without AWS credentials. Sharing one instance reduces the lab's database footprint, but it does not provide independent failure domains for the three services or make the whole platform highly available.

The Week 3 AWS environment has already been cleaned up. This is a fresh target deployment, not a live data migration: no old order, inventory, or notification records are copied. If any local SQLite database is discovered and its records matter, stop and decide whether to preserve them. Export, transform, reconcile row counts and sample records, then cut over; do not simply point the app at an empty database.

## Migration waves

1. **Foundation:** recreate the remote Terraform state backend, then review the dev Terraform plan. Provision private RDS PostgreSQL, KMS encryption, managed master credentials, the RDS security group, and scoped IRSA roles. Application roles get IAM DB authentication; only the one-shot schema bootstrap role reads the master secret.
2. **Schema bootstrap:** Helm runs an idempotent pre-install/pre-upgrade Job. It creates the `orders`, `inventory`, and `notifications` schemas, the three `rds_iam` application roles, their required tables, and initial stock. Grants are limited to each service's required table operations.
3. **Application cutover:** build and scan all service images, push immutable digests, and deploy the Helm chart. Product and Order HPAs are installed; a separate one-replica outbox relay owns event publishing.
4. **Validation:** confirm the migration Job completed and `/ready` succeeds for each DB-backed service. Verify order create/list/get, reservation and inventory count, idempotent notification writes, and the EventBridge/SQS notification path. Check DLQ depth, RDS connections/CPU, HPA metrics, Pod logs, and the CloudWatch dashboard.
5. **Rollback:** stop application rollout if the schema job or smoke checks fail. Since the former AWS environment was removed, a rollback to the old SQLite/EBS deployment is not an automatic data-preserving option. For a future production cutover, take and verify a database snapshot/export, define a write-freeze or dual-write strategy, and test restoring the previous application and data before starting migration.

## Cost controls and measurement

Configured controls include a single NAT Gateway, a small Multi-AZ RDS instance by default, RDS storage autoscaling capped at 50 GiB, bounded EKS capacity, ECR lifecycle retention, 14-day EKS/RDS database log retention, and S3 lifecycle expiration. Enhanced Monitoring samples RDS OS metrics every 60 seconds; its `RDSOSMetrics` CloudWatch Logs group has a separate default retention period and ingestion/storage cost. PostgreSQL exports DDL and slow-query logs (queries taking at least one second); it does not log every statement because SQL can contain sensitive data. Product/Order HPA min/max is 1/3 replicas. HPA scales Pods; Karpenter can add bounded node capacity when Pods cannot be scheduled.

The Terraform cost budget defaults to a $200 monthly threshold and creates 80% actual / 100% forecast notifications only when `MONITORING_ALERT_EMAIL` is set. AWS Budgets is alerting, not a spending cap. It cannot terminate infrastructure.

No before/after AWS Cost Explorer data is available because the Week 3 resources were cleaned up and this update has not been applied. Before presenting measured savings, record a comparable billing window and complete this table with account evidence:

| Candidate | Evidence to collect | Change to evaluate | Actual monthly impact |
|---|---|---|---|
| RDS class and Multi-AZ | CPU, connections, storage, failover result, and RDS cost for the same period | Measure the standby cost and availability benefit; right-size only after observing workload and recovery needs | Not measured yet |
| NAT Gateway | NAT hourly and data-processing charges; identify private-subnet egress traffic | Compare existing single NAT with VPC endpoints for high-volume AWS services; include endpoint hourly cost | Not measured yet |
| EKS compute | Node CPU/memory requests versus observed utilization and EC2/EKS charges | Right-size requests/nodes; consider node autoscaling only when workload and schedule justify the operational cost | Not measured yet |
| CloudWatch | Ingested GB, retained GB, Enhanced Monitoring log volume, and custom metric cardinality | Keep application logs at 14-day retention; review `RDSOSMetrics` retention and avoid unnecessary high-frequency sampling | Not measured yet |
| ECR | Stored image GB and old digest usage | Keep recent deployable digests and remove stale images through lifecycle policy | Not measured yet |

For a credible cost report, capture the baseline before applying an optimization, estimate the expected change, apply one change at a time, and compare the same billing dimensions after enough data has accrued. Do not present estimates as realized savings.

## Production deltas

Before production, define RTO/RPO and test Multi-AZ failover and point-in-time restore. Enable deletion protection and final snapshots, private API access, database connection pooling, formal versioned schema migrations, and verified PostgreSQL TLS server certificates. Add an authenticated API boundary and test the rollback procedure with representative data.
