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
      securityContext:
        fsGroup: 10001
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
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
            runAsNonRoot: true
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
          volumeMounts:
            - name: tmp
              mountPath: /tmp
          readinessProbe:
            exec:
              command:
                - python
                - -c
                - "import os,sys,time; p='/tmp/event-producer-health'; sys.exit(0 if os.path.exists(p) and time.time()-os.path.getmtime(p)<120 else 1)"
            periodSeconds: 30
            timeoutSeconds: 5
            failureThreshold: 3
          livenessProbe:
            exec:
              command:
                - python
                - -c
                - "import os,sys,time; p='/tmp/event-producer-health'; sys.exit(0 if os.path.exists(p) and time.time()-os.path.getmtime(p)<120 else 1)"
            periodSeconds: 30
            timeoutSeconds: 5
            failureThreshold: 3
      volumes:
        - name: tmp
          emptyDir: {}
