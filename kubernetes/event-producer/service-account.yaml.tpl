apiVersion: v1
kind: ServiceAccount
metadata:
  name: event-producer
  namespace: monitoring-dev
  annotations:
    eks.amazonaws.com/role-arn: EVENT_PRODUCER_ROLE_ARN_PLACEHOLDER
