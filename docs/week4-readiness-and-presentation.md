# Week 4 Readiness and Presentation Notes

## Readiness summary

The core Coffee Store platform is implemented and has live application, CloudWatch, alerting, and security-scan evidence. The project is not fully evidence-complete yet: there is no measured Cost Explorer baseline or realized savings comparison, the ALB 4xx spike is unresolved, and the latest security evidence predates the local CloudTrail Terraform addition. Present those as open items rather than implying they are complete.

| Assignment area | Status | Evidence or remaining work |
|---|---|---|
| Containers and Kubernetes | Implemented; operational proof is partial | The application repo defines Helm workloads, health probes, CPU HPAs, bounded VPA policies, immutable image digests, and deployment smoke tests. Existing order/email screenshots prove a working customer path. Capture current Pods, Ingress, HPA, and VPA status if available. |
| IaC and delivery automation | Implemented; current change needs CI | Terraform is modular, and the workflows validate code, run scans, use GitHub OIDC, deploy through Helm, and support scheduled drift checks. The CloudTrail code has not been applied and must pass CI and a reviewed remote-state plan first. The application deployment workflow has no `environment:` declaration for GitHub protected-environment approvals; verify repository settings or treat this as a gap. |
| Security operations | Implemented with documented lab tradeoffs | The available Platform CI evidence reports 221 Checkov passes, zero failures, and 40 skips; Gitleaks reported no leaks in the one commit scanned. Trivy completed, but the saved output does not show finding totals. Rerun Platform CI after the CloudTrail change and save the current scan summary. Do not claim GuardDuty, Inspector, or Security Hub is deployed. |
| Observability and incident response | Core path demonstrated; one metric needs follow-up | CloudWatch logs and resource metrics are present. The synthetic notification-DLQ test demonstrated alarm detection, SNS email delivery, and recovery. It was injected directly into the DLQ; it did not test automatic dead-lettering from the primary queue. Investigate the ALB 4xx spike. No 5xx datapoints in the captured range do not prove there were zero errors. |
| Migration, cost, and optimization | Plan is documented; cost results are pending | Migration waves, validation, rollback, and five optimization candidates are documented. There is no Cost Explorer baseline or measured before/after impact yet, so describe these as recommendations—not realized savings. `Project` and `Environment` cost-allocation keys were shown active; use the exact `Environment` key (not the separate key with a trailing space). |
| Architecture and final presentation | Architecture is documented; slide deck not in these repos | The platform README contains Mermaid architecture diagrams. No PowerPoint file was found in the platform or application repositories. |

## Evidence to use

- Customer order and notification: `demo-evidence/coffee-store-orders-and-notifications.png` and `demo-evidence/coffee-store-sns-order-email.png`.
- Runtime telemetry: `demo-evidence/week4-cloudwatch-platform-dashboard.png`, `demo-evidence/week4-cloudwatch-order-service-log.png`, and `demo-evidence/week4-alb-monitoring.png`.
- Alert test: use the alarm-triggered, successful-action/email, recovered, and zero-count screenshots together. Explain that the test message was sent directly to the DLQ.
- Security: the current saved scan evidence is tied to commit `3d3679f`; refresh it after the CloudTrail code passes CI.
- Cost: add a Cost Explorer screenshot grouped by service and, where populated, filtered by the active `Project`/`Environment` tags. Until then, state that cost recommendations are proposed and savings are not measured.

## 15-minute presentation outline

### 0:00-2:00 — Business problem and architecture

“The business problem was inconsistent, manually managed retail infrastructure. I rebuilt the development platform from code so networking, EKS, the database, deployment standards, and operational controls are repeatable. Drift detection identifies changes outside Terraform, while scaling and retention policies help control cost.”

Show the architecture diagram and distinguish the customer order/notification path from the separate monitoring-event pipeline.

### 2:00-6:00 — Live application and containers

Place a test order, show it in order history, then show the matching in-app notification and email. Explain that the app uses separate services and that the AWS deployment uses EKS, Helm, probes, and digest-pinned images. Do not imply the email screenshot alone proves every internal EventBridge/SQS hop.

### 6:00-9:00 — IaC, CI/CD, and Kubernetes operations

Show Terraform modules and the workflow gates: validation, security scans, OIDC credentials, image scanning, Helm deployment, and post-deploy smoke tests. If showing autoscaling, use current HPA/VPA status. Describe CloudTrail as pending until the current code passes CI, the plan is reviewed, and it is applied.

### 9:00-12:00 — Security, observability, and failure recovery

Show the CloudWatch dashboard and a structured application health log. Walk through the synthetic DLQ test: alarm entered ALARM, the SNS action succeeded and emailed, then the alarm returned to OK after cleanup. State that the test injected directly into the DLQ. The captured ALB view includes a 4xx spike that is still under investigation; do not call the range error-free.

### 12:00-14:00 — Migration and cost optimization

Explain the fresh deployment and target database design, the migration validation and rollback plan, and the cost controls. Show Cost Explorer only after collecting the baseline. Present at least three recommendations with the observed usage/cost, proposed change, risk or tradeoff, and measured result. Until a before/after comparison exists, say “identified for evaluation,” not “savings achieved.”

### 14:00-15:00 — Risks, lessons, and next steps

Call out the lab tradeoffs: one NAT Gateway, a single baseline EKS node, Multi-AZ RDS cost, and the remaining ALB 4xx investigation. Close with the next evidence actions: rerun CI, review CloudTrail plan, capture Cost Explorer, and resolve or explain the 4xx spike.

## Claims to avoid until verified

- “We saved X dollars” or “cost decreased by X%” without a comparable Cost Explorer baseline and after measurement.
- “CloudTrail is enabled” until the Terraform plan is reviewed and the apply succeeds. The proposed trail captures account-wide management events, not only this project.
- “There were zero errors” based only on missing 5xx datapoints in the selected ALB chart range.
- “The DLQ automatically recovered messages” based on manually polling/redriving or directly injecting a test message.
- “All images have zero vulnerabilities” based only on a successful Trivy step without its finding summary.
