apiVersion: apps/v1
kind: Deployment
metadata:
  name: event-producer
  namespace: monitoring-dev
  labels:
    app.kubernetes.io/name: event-producer
    app.kubernetes.io/part-of: guduf-retail-eks
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: event-producer
  template:
    metadata:
      labels:
        app.kubernetes.io/name: event-producer
        app.kubernetes.io/part-of: guduf-retail-eks
    spec:
      serviceAccountName: event-producer
      containers:
        - name: event-producer
          image: IMAGE_URI_PLACEHOLDER
          imagePullPolicy: IfNotPresent
          env:
            - name: EVENTS_QUEUE_URL
              value: EVENTS_QUEUE_URL_PLACEHOLDER
            - name: SERVICE_NAME
              value: kubernetes-event-producer
            - name: EVENT_SEVERITY
              value: info
            - name: INTERVAL_SECONDS
              value: "60"
          resources:
            requests:
              cpu: 50m
              memory: 128Mi
            limits:
              cpu: 250m
              memory: 256Mi
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
