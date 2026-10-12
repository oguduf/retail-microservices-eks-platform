# Grafana browser access

Grafana is private by default. The optional `public-https` deployment creates an internet-facing Application Load Balancer (ALB), redirects HTTP to HTTPS, and relies on Grafana's own username/password login. This is a development-lab access pattern, not the production SSO/MFA design.

The endpoint is `https://grafana.omergroup.click`. The EKS AWS Load Balancer Controller discovers the matching ACM certificate from the Ingress hostname, so the certificate must be issued in the same AWS Region as the ALB (`us-east-2`).

## One-time setup

1. In the AWS Console, open **Certificate Manager (ACM)** and select **US East (Ohio), us-east-2**.
2. Request a public certificate for `grafana.omergroup.click` using DNS validation.
3. Use ACM's **Create records in Route 53** action for the validation record. Wait until the certificate status is **Issued**.
4. Confirm the repository Actions secret `GRAFANA_ADMIN_PASSWORD` is set to a strong, unique password. It is the Grafana `admin` password; do not put it in a repository file.

## Deploy and create the DNS alias

1. Confirm **Platform CI** succeeds for the `dev` commit you will deploy.
2. Go to **Actions → Deploy Prometheus and Grafana → Run workflow**, select branch `dev`, and set **Grafana access** to `public-https`.
3. After the deployment succeeds, open its **Grafana HTTPS endpoint setup** summary and copy the ALB hostname shown there.
4. In Route 53, open the public hosted zone for `omergroup.click` and create an `A` record named `grafana`. Turn **Alias** on and select the Application Load Balancer in `us-east-2` that matches the hostname from the workflow summary.
5. After DNS propagates, open `https://grafana.omergroup.click`. Sign in with username `admin` and the password stored in `GRAFANA_ADMIN_PASSWORD`.

If the browser reports a certificate or DNS error, verify the ACM certificate is **Issued** in `us-east-2`, the alias targets the correct ALB, and the hostname is exactly `grafana.omergroup.click`. Check the deployment workflow and the Ingress events before rerunning.

## Security and cost

The ALB is reachable from the internet, but its listener uses HTTPS and Grafana still requires its login. Keep the admin password unique and private. For production, replace the single Grafana admin login with SSO (such as Cognito/OIDC) and MFA, consider source-IP restrictions or WAF protections, and use durable monitored storage and a highly available monitoring design. An internet-facing ALB incurs ongoing charges while it exists.

To return Grafana to private-only access, rerun the workflow with **Grafana access** set to `private`; then remove the `grafana` Route 53 alias record. Removing the Ingress causes the controller to delete its ALB. The ACM certificate can remain for reuse or be deleted separately when no longer needed.
