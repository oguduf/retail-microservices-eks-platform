# Architecture

## Request Flow

```text
User
  |
Application Load Balancer
  |
Kubernetes Ingress
  |
Amazon EKS Services
```

## Service and Event Flow

```text
Order Service
  |
  | OrderCreated
  v
Amazon EventBridge
  |--------------------> Inventory Service
  |                         |
  |                         | InventoryReserved or InventoryFailed
  |                         v
  |--------------------> Order Service
  |
  |--------------------> Notification Service
```

## Data Stores

- Product Service uses MySQL for catalog data.
- Order Service uses MySQL for order data.
- Inventory Service uses DynamoDB for stock and reservations.
- Notification Service uses DynamoDB for notification records.
- Product Service uses ElastiCache for product catalog caching.

## Reliability

- Amazon SQS queues decouple event consumers.
- Dead-letter queues retain failed messages.
- Kubernetes readiness and liveness probes detect unhealthy containers.
- Horizontal Pod Autoscalers scale services based on demand.