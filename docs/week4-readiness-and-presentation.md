# Week 4 Readiness and Presentation Notes

## Readiness summary

The core Coffee Store platform is implemented and has live application, CloudWatch, alerting, CloudTrail, Cost Explorer, and security-workflow evidence. The latest screenshots shared for this review show successful Platform CI, application CI, and application security workflow runs. The project has a short-period Cost Explorer baseline, but no measured before/after savings comparison. The ALB chart contains a historical 4xx spike; describe what the evidence shows without claiming the captured period was error-free or reopening the investigation already reviewed with the project owner.

| Assignment area | Status | Evidence or remaining work |
|---|---|---|
| Containers and Kubernetes | Implemented; operational proof is partial | The application repo defines Helm workloads, health probes, CPU HPAs, bounded VPA policies, immutable image digests, and deployment smoke tests. Existing order/email screenshots prove a working customer path. Capture current Pods, Ingress, HPA, and VPA status if available. |
| IaC and delivery automation | Implemented; approval gate configured | Terraform is modular, and the workflows validate code, run scans, use GitHub OIDC, deploy through Helm, and support scheduled drift checks. CloudTrail is applied and the trail logging status is verified in AWS. The application deployment workflow references the `dev` GitHub Environment; required reviewers were configured in GitHub. The approval pause itself will be exercised on a future deployment; no deployment is needed just to complete this evidence review. The latest Platform CI run shown for review succeeded. |
| Security operations | Implemented with documented lab tradeoffs | The latest screenshots shared for review show the Platform CI scan and both application CI/security workflows succeeded. A successful workflow means configured gates passed; it does not by itself prove that every scanner found zero issues. The saved scan output does not provide current Trivy finding totals or a High/Critical ownership/remediation summary; capture those from the workflow logs/artifact before presenting. Do not claim GuardDuty, Inspector, or Security Hub is deployed. |
| Observability and incident response | Core path demonstrated; known chart caveat | CloudWatch logs and resource metrics are present. The synthetic notification-DLQ test demonstrated alarm detection, SNS email delivery, and recovery. It was injected directly into the DLQ; it did not test automatic dead-lettering from the primary queue. The ALB chart includes a historical 4xx spike that was reviewed; describe the observation without claiming the captured range was error-free. |
| Migration, cost, and optimization | Plan and refreshed baseline documented; savings not measured | Migration waves, validation, rollback, and five optimization candidates are documented. The refreshed project-specific Cost Explorer export shows $17.141 in unblended cost for October 7–11, 2026; October 11 is a partial day, so this is not a monthly estimate. The older October 7–10 export is retained as a prior snapshot and differs from the refreshed report. No before/after impact has been measured, so describe the candidates as recommendations—not realized savings. `Project` and the correctly named `Environment` cost-allocation keys were shown active. |
| Architecture and final presentation | Architecture is documented; slide deck not in these repos | The platform README contains Mermaid architecture diagrams. No PowerPoint file was found in the platform or application repositories. |

## Evidence to use

- Customer order and notification: `demo-evidence/coffee-store-orders-and-notifications.png` and `demo-evidence/coffee-store-sns-order-email.png`.
- Runtime telemetry: `demo-evidence/week4-cloudwatch-platform-dashboard.png`, `demo-evidence/week4-cloudwatch-order-service-log.png`, and `demo-evidence/week4-alb-monitoring.png`.
- Alert test: use the alarm-triggered, successful-action/email, recovered, and zero-count screenshots together. Explain that the test message was sent directly to the DLQ.
- Security: the latest screenshots shared for this review show Platform CI, application CI, and application security workflows succeeded. Before the presentation, save the current run screenshots/log summaries in this evidence folder and record scanner finding totals and any High/Critical dispositions. The existing saved Platform CI screenshot may still describe the older `3d3679f` run.
- Cost: the October 7–11 Cost Explorer export and usage-type screenshots show the short-period AWS billing baseline; the Infracost push-to-dev screenshot separately shows a $174 projected monthly cost from Terraform configuration. Explain that actual billed spend and a pre-deployment estimate are different measures. Neither is evidence of realized savings. October 11 is partial; use the evidence and figures consistently in the presentation.

## 15-minute presentation outline

### 0:00-2:00 — Business problem and architecture

“The business problem was inconsistent, manually managed retail infrastructure. I rebuilt the development platform from code so networking, EKS, the database, deployment standards, and operational controls are repeatable. Drift detection identifies changes outside Terraform, while scaling and retention policies help control cost.”

Show the architecture diagram and distinguish the customer order/notification path from the separate monitoring-event pipeline.

### 2:00-6:00 — Live application and containers

Place a test order, show it in order history, then show the matching in-app notification and email. Explain that the app uses separate services and that the AWS deployment uses EKS, Helm, probes, and digest-pinned images. Do not imply the email screenshot alone proves every internal EventBridge/SQS hop.

### 6:00-9:00 — IaC, CI/CD, and Kubernetes operations

Show Terraform modules and the workflow gates: validation, security scans, OIDC credentials, image scanning, Helm deployment, and post-deploy smoke tests. If showing autoscaling, use current HPA/VPA status. Describe CloudTrail as active: the trail is multi-Region, logs management events to S3, has log-file validation and SSE-KMS enabled, and shows recent log delivery. It is an account trail, not organization-wide.

### 9:00-12:00 — Security, observability, and failure recovery

Show the CloudWatch dashboard and a structured application health log. Walk through the synthetic DLQ test: alarm entered ALARM, the SNS action succeeded and emailed, then the alarm returned to OK after cleanup. State that the test injected directly into the DLQ. The captured ALB view includes a 4xx spike that is still under investigation; do not call the range error-free.

### 12:00-14:00 — Migration and cost optimization

Explain the fresh deployment and target database design, the migration validation and rollback plan, and the cost controls. Show the Cost Explorer baseline exports and present at least three recommendations with observed usage/cost, proposed change, and risk or tradeoff. State clearly that measured before/after savings are not available; say “identified for evaluation,” not “savings achieved.”

### 14:00-15:00 — Risks, lessons, and next steps

Call out the lab tradeoffs: one NAT Gateway, a single baseline EKS node, Multi-AZ RDS cost, and the historical ALB 4xx spike shown in the captured chart. Close with remaining evidence actions: record current scanner finding totals/dispositions and assemble the final presentation. No CloudTrail apply, Cost Explorer baseline capture, CI rerun, or application redeployment is required for these already verified items.

## Claims to avoid until verified

- “We saved X dollars” or “cost decreased by X%” without a comparable Cost Explorer baseline and after measurement.
- “CloudTrail is organization-wide” or captures only project events; the verified trail is multi-Region for account management events.
- “There were zero errors” based only on missing 5xx datapoints in the selected ALB chart range.
- “The DLQ automatically recovered messages” based on manually polling/redriving or directly injecting a test message.
- “All images have zero vulnerabilities” based only on a successful Trivy step without its finding summary.
