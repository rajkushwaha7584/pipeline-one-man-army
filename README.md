# One Man Army: Three-Tier DevSecOps Pipeline

This repository is a starting point for automating a three-tier application with GitHub Actions, Docker, Terraform, Helm, and security reporting. It is not yet a one-click production deployment: the checked-in Terraform currently creates a single public EC2/k3s host, and the Helm chart currently runs MySQL inside Kubernetes. The target design below uses private RDS and a managed Kubernetes control plane, so infrastructure work is still required before enabling CD.

## Target Architecture

```text
GitHub Actions
	PR: app checks -> Docker builds -> Trivy / optional Snyk and Sonar -> Terraform validate -> Helm lint
	main: repeat checks -> push versioned images to ECR -> Terraform plan/apply (approval) -> Helm deploy -> ZAP DAST
																						|
																						v
												Public ALB / AWS Load Balancer Controller
																						|
															EKS managed node groups (EC2/ASG)
																	 private application subnets
																						|
											 private RDS MySQL subnets + Secrets Manager

Prometheus + Grafana: installed into EKS with Helm
Security reports: GitHub Pages (public) and/or Actions artifacts
```

For Kubernetes, prefer EKS with managed node groups over putting one k3s control plane in an EC2 Auto Scaling Group. EKS node groups use EC2 Auto Scaling Groups under management, while the control plane is managed and survives worker replacement. Put worker nodes and RDS in private subnets; expose the app through an internet-facing ALB. Private subnets need outbound access (usually NAT gateways or VPC endpoints) for image pulls and updates.

## Pipeline Starter

The workflow at `.github/workflows/pipeline.yml` runs application checks, builds both Docker images, scans them with Trivy, validates Terraform and Helm, and saves scan outputs as a workflow artifact. On pushes to `main`, it also publishes the generated report page using GitHub Pages. Snyk, SonarCloud, and ZAP steps activate when their corresponding repository variables are configured.

The workflow deliberately does not apply Terraform or deploy to a cluster yet. The current infrastructure and chart need to be migrated to the target topology first. For a safe CD flow, use a separate protected GitHub Environment for each environment and require approval for production Terraform apply/deployment.

### GitHub configuration

Set these repository variables:

| Variable             | Purpose                                                                  |
| -------------------- | ------------------------------------------------------------------------ |
| `ENABLE_SNYK`        | Set to `true` to enable the Snyk dependency scan                         |
| `ENABLE_SONAR`       | Set to `true` to enable SonarCloud analysis                              |
| `SONAR_ORGANIZATION` | SonarCloud organization key                                              |
| `SONAR_PROJECT_KEY`  | SonarCloud project key                                                   |
| `APP_BASE_URL`       | Deployed app URL; setting it enables the passive OWASP ZAP baseline scan |

Set these repository secrets only for integrations you enable:

| Secret        | Purpose          |
| ------------- | ---------------- |
| `SNYK_TOKEN`  | Snyk API token   |
| `SONAR_TOKEN` | SonarCloud token |

GitHub Pages must be enabled with **Build and deployment > Source: GitHub Actions**. The report page is public; it can reveal dependency names and vulnerability details. Do not publish reports containing credentials, private URLs, or customer data. Pull-request runs keep reports as Actions artifacts instead of publishing them.

### AWS authentication for the future deploy stage

Use GitHub Actions OIDC, not long-lived `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` keys. Create an AWS IAM role whose trust policy restricts `token.actions.githubusercontent.com` to this repository and the protected deployment environment. Grant only the required ECR push, Terraform state/resource, EKS describe, and deployment permissions. Configure the workflow with `id-token: write`, `aws-actions/configure-aws-credentials`, and the role ARN as an environment variable. Do not put AWS credentials in source files or Terraform state.

The production workflow will also need non-secret configuration such as AWS region, ECR repository names, EKS cluster name, Helm release/namespace, and image tag. Database credentials should be generated/stored in AWS Secrets Manager and mounted or synced into Kubernetes; they should not be GitHub Actions variables.

## Recommended Build-Out Order

1. Move Terraform state to an encrypted, versioned S3 backend with locking, then remove state files from Git history if they contain infrastructure details or secrets. Rotate any credential that has ever been committed.
2. Extend Terraform to create public and private subnets across at least two Availability Zones, NAT/VPC endpoints, EKS and managed node groups, ECR, private RDS MySQL, Secrets Manager, IAM roles, and security groups. Add an ALB through the AWS Load Balancer Controller.
3. Update the Helm chart to use the RDS endpoint instead of deploying its MySQL StatefulSet. Keep DB credentials in a Kubernetes Secret populated from Secrets Manager. Add readiness/liveness probes, resource requests/limits, and ingress configuration.
4. Add Prometheus/Grafana through a pinned Helm chart (commonly `kube-prometheus-stack`), configure persistence and retention, and restrict dashboard access.
5. Add a protected deploy workflow: build and push SHA-tagged images to ECR, apply reviewed Terraform changes, run `helm upgrade --install`, wait for rollout, run smoke tests, then run ZAP baseline against the deployed URL. Promote the exact same image digest from dev to prod.
6. Publish security reports only after deciding they may be public. Keep complete logs as short-retention Actions artifacts as well.

## Current Repository Notes

- `apps/backend` is a small Express API with a MySQL health endpoint. There is currently no automated unit-test script or committed npm lockfile; add tests and commit `package-lock.json` for reproducible installs.
- `apps/frontend` is a static Nginx page.
- The Terraform workflows already validate and manually apply infrastructure, but use static AWS credentials and are not a replacement for the application deploy workflow.
- The existing k3s bootstrap, Terraform and Helm files are an in-progress baseline. Review their state and resource changes before running `terraform apply` or `destroy`.

## Run Checks Locally

```bash
cd apps/backend
npm install
npm test --if-present
cd ../..
helm lint helm/three-tier
helm template three-tier helm/three-tier --namespace three-tier
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

The GitHub Actions workflow runs these checks in CI; local Terraform initialization may update the provider lock file, so review that diff before committing.

ok
