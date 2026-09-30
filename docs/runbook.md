# Operations Runbook

This runbook describes how to diagnose, recover, and verify common operational failures in the Retail Microservices Platform on AWS EKS.

## Deployment Failure

If a deployment fails:

1. Check the GitHub Actions workflow logs.
2. Check whether the Kubernetes pods are running.
3. Check the application logs.
4. Fix the issue and deploy again.
5. Roll back to the last working version if necessary.

## Application Failure

If an application service stops working:

1. Check whether its container or Kubernetes pod is running.
2. Check its logs for errors.
3. Check its database, messaging, and configuration dependencies.
4. Fix the root cause.
5. Verify that the application works again.

## Database Failure

If a service cannot connect to its database:

1. Check the application logs.
2. Confirm the database is available.
3. Confirm networking and security rules allow the connection.
4. Confirm credentials and connection settings are correct.
5. Test the application again.

## Event Processing Failure

If orders, inventory, or notifications do not update:

1. Check the EventBridge rules.
2. Check the SQS queues.
3. Check the service processing the message.
4. Check the dead-letter queue for failed messages.
5. Fix the issue before retrying failed messages.

## Monitoring

Monitor:

- Application logs
- Kubernetes pod health
- CPU and memory usage
- Database health
- SQS queue depth
- Failed messages in dead-letter queues