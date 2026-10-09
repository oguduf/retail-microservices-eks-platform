# Operations Runbook

## Event does not appear in the API

1. Check the event-producer Pod status and logs in the `monitoring-dev` namespace.
2. Check SQS approximate queue depth and whether messages are being received.
3. Check the processor Lambda logs and invocation errors in CloudWatch.
4. Inspect the dead-letter queue for failed messages and the Lambda error details before redriving.
5. Confirm the producer service account is associated with the expected IRSA role and that its role can send to the correct queue.
6. Confirm the processor role can write to the expected DynamoDB table and S3 prefix.
7. Query the event through API Gateway after fixing the cause.

## API request fails

1. Check the API Gateway stage and route integration.
2. Check query Lambda invocation metrics and CloudWatch logs.
3. Confirm the query Lambda role has read access to the event table.
4. Verify the requested event ID exists in DynamoDB.

## Critical notification is not received

1. Confirm event severity is exactly `critical` according to the event schema.
2. Check processor Lambda logs and SNS publish errors.
3. Confirm the SNS email subscription has been confirmed.
4. Check the topic subscription and email spam/quarantine.

## Coffee Store is not reachable

1. Check Deployments, Pods, HPAs, and Services in `coffee-store` with `kubectl get pods,deployments,hpa,services -n coffee-store`.
2. Inspect failing workloads with `kubectl describe pod` and `kubectl logs`; check readiness and liveness probe results.
3. Confirm the AWS Load Balancer Controller is running in `kube-system`, then inspect the Ingress and its events with `kubectl describe ingress coffee-store -n coffee-store`.
4. Inspect the affected service's `/ready` probe and PostgreSQL connectivity. Verify its schema-specific DB role, RDS IAM authentication, private endpoint, and the RDS security-group rule from EKS nodes. These services no longer need app PVCs.
5. The GitHub workflow is manual. Verify the five ECR tags and that its OIDC role is allowed both to push images and to access the EKS cluster.

After a failed Helm rollout, check `kubectl logs job/coffee-store-orders-db-migration -n coffee-store` first. Then inspect affected Pod events/logs and `/ready`; verify `ORDERS_DATABASE_HOST`, secret ARN, the service-account annotation, `rds-db:connect`, the RDS security group, and that the database role (`orders_app`, `inventory_app`, or `notifications_app`) has `rds_iam` and schema grants. Do not grant runtime roles access to the master secret. If HPA shows `<unknown>`, check Metrics Server and `kubectl top pods -n coffee-store` before tuning CPU thresholds. Check the CloudWatch dashboard and RDS alarms for load/connection/storage evidence.

Single-AZ RDS and its disposable-lab destroy settings are not an HA architecture; RDS deletion skips a final snapshot. Back up anything needed before infrastructure teardown. For production, use Multi-AZ or Aurora only after defining availability, recovery, and cost requirements.

## Order appears but its update or email is missing

1. Confirm the order exists and inspect the Order service logs for outbox publishing errors.
2. Check the `OrderCreated` EventBridge rule and target failure metrics. A failed target delivery can go to the notification DLQ.
3. Check notification SQS messages available, in flight, and in its DLQ. Inspect the Notification service Pod logs and its IRSA role's SQS permissions.
4. Check for other consumers of the notification queue, including manually created EventBridge Pipes. Competing consumers can take messages before the Notification service sees them.
5. If the update is visible in the UI but email is missing, inspect SNS publish errors and confirm the email subscription. Do not replay messages until you check for an existing notification to avoid duplicates.

## Terraform changes

1. Run the Terraform workflow with operation `plan` from `dev`.
2. Review every proposed create, update, and destroy action, especially shared VPC and EKS resources.
3. Confirm `Platform CI` passed on the exact `dev` commit, then apply only after the plan matches the intended change. The workflow enforces this CI check for a normal `apply`; plan, drift detection, cleanup, and destroy operations remain available without it.
4. Verify the AWS resource and Terraform workflow result.

## Kubernetes autoscaling

1. After Terraform apply, run `Deploy Karpenter autoscaling` from GitHub Actions. It reads the controller role and node role from Terraform state, installs the pinned controller, then applies the dev `EC2NodeClass` and `NodePool`.
2. In the application repository, run `Deploy Coffee Store to EKS` after its CI passes. It installs Metrics Server (HPA metrics) and the pinned VPA components before deploying the Helm chart.
3. Check `kubectl get hpa,vpa -n coffee-store`; inspect `kubectl describe hpa` and `kubectl describe vpa` for current metrics, recommendations, and conditions.
4. Check `kubectl get nodepool,ec2nodeclass,nodeclaims` and `kubectl get nodes -L karpenter.sh/nodepool`. Karpenter only adds a node when Pods are unschedulable; it may consolidate underused nodes after two minutes.
5. CPU HPA and VPA memory policies are deliberately split for the same Deployment. VPA can change requests and limits within chart-defined bounds; in-place resize is preferred where supported, otherwise the Pod may be recreated. The event outbox relay remains a single replica to avoid duplicate publishers.
6. The dev NodePool uses on-demand instances from C/M/R families and is limited to three Karpenter nodes, 12 vCPU, and 48 GiB. Karpenter evaluates limits asynchronously, so rapid scale-out may briefly exceed them; they do not guarantee a fixed AWS bill. The baseline managed node remains at one node; it is a single point of failure accepted for this cost-focused lab.

If HPA reports unknown CPU metrics, verify Metrics Server and `kubectl top pods -n coffee-store`. If VPA has no recommendation, check the VPA recommender/updater/admission-controller Pods in `kube-system` and allow time for workload history to accumulate. If Pods remain Pending, inspect Pod events and Karpenter logs before increasing limits; also check EC2 quotas, subnet IP capacity, and NodePool requirements.

Before Terraform destruction, run `cleanup-kubernetes`. It removes the app workloads, asks Karpenter to drain and terminate its NodeClaims, and uninstalls the controller. Do not continue to destroy-apply if the workflow reports remaining NodeClaims.

## Cost and cleanup

The NAT Gateway, EKS control plane/nodes, ALB, RDS, and CloudWatch ingestion can incur charges. A monthly AWS Budget sends alerts only; it does not stop resources. Before applying/destroying, bootstrap and preserve the S3 Terraform state bucket, inspect the exact plan, and verify any Orders data is disposable because the lab RDS resource skips a final snapshot.
