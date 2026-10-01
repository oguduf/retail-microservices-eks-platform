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

## Terraform changes

1. Run the Terraform workflow with operation `plan` from `dev`.
2. Review every proposed create, update, and destroy action, especially shared VPC and EKS resources.
3. Apply only after the plan matches the intended change.
4. Verify the AWS resource and Terraform workflow result.

## Cost and cleanup

The NAT Gateway, EKS cluster/nodes, RDS, and Valkey can continue to incur charges. When the project is paused or complete, review Terraform state and the plan, then destroy resources in dependency order while preserving the Terraform state bucket until all managed infrastructure is removed.
