# One Man Army: Three-Tier DevSecOps Pipeline

This repository combines SkillPulse (Go/Gin, MySQL, and a vanilla-JS frontend) with GitHub Actions, Docker, Terraform, Helm, and security reporting.

## Current Deployment

Terraform currently creates a public EC2 host running k3s and a MySQL RDS instance in private subnets. Helm deploys the backend and Nginx frontend, initializes the RDS schema on first installation, and routes traffic through k3s Traefik. This is a starter deployment, not the separate production target of EKS, managed node groups, and an ALB. Prometheus/Grafana are not configured yet.

Review Terraform plans and costs before applying. The Terraform state files in this repository are sensitive operational data; do not publish them, and migrate to secured remote state before collaborating or using production.

## GitHub Actions

`.github/workflows/pipeline.yml` runs Go test/vet, builds backend and frontend images, scans both with Trivy, validates Terraform and Helm, and publishes security reports to GitHub Pages on main. Set `PUBLISH_IMAGES=true` to push SHA-tagged and `latest` images to Docker Hub on pushes to main. Optional Snyk, SonarCloud, and OWASP ZAP scans are enabled through repository variables.

`.github/workflows/helm-apply.yml` is a manually dispatched Helm deployment. GitHub Actions authenticates to AWS using OIDC and asks Systems Manager to run Helm on the EC2 host; it does not expose the Kubernetes API publicly. The host downloads the selected commit's source archive from GitHub's public codeload endpoint, so private repositories need an authenticated artifact handoff before using this workflow. Terraform apply remains a separate, reviewed manual operation.

### Repository variables

| Variable              | Purpose                                                  |
| --------------------- | -------------------------------------------------------- |
| `AWS_REGION`          | Region containing the deployment EC2 host                |
| `EC2_INSTANCE_ID`     | EC2 instance ID from `terraform output -raw instance_id` |
| `PUBLISH_IMAGES`      | Set to `true` to publish images from main                |
| `BACKEND_IMAGE_REPO`  | Optional backend image repository override               |
| `FRONTEND_IMAGE_REPO` | Optional frontend image repository override              |
| `DB_SECRET_NAME`      | Kubernetes secret name; defaults to `app-db`             |
| `ENABLE_SNYK`         | Set to `true` to enable Snyk                             |
| `ENABLE_SONAR`        | Set to `true` to enable SonarCloud                       |
| `SONAR_ORGANIZATION`  | SonarCloud organization key                              |
| `SONAR_PROJECT_KEY`   | SonarCloud project key                                   |
| `APP_BASE_URL`        | Enables the passive ZAP scan when set                    |

### Repository secrets

| Secret               | Purpose                                                             |
| -------------------- | ------------------------------------------------------------------- |
| `AWS_ROLE_ARN`       | IAM role trusted for this repository's GitHub Actions OIDC identity |
| `DOCKERHUB_USERNAME` | Docker Hub username for image publishing/deployment                 |
| `DOCKERHUB_TOKEN`    | Docker Hub token with image push permission                         |
| `SNYK_TOKEN`         | Snyk token when that scan is enabled                                |
| `SONAR_TOKEN`        | SonarCloud token when that scan is enabled                          |

The Actions IAM role needs narrowly scoped `ssm:SendCommand` and `ssm:GetCommandInvocation` permissions for the target EC2 instance and `AWS-RunShellScript`. The EC2 role needs SSM managed-instance permissions and access to the Secrets Manager database secret. Set an OIDC trust condition for this repository and protect the `dev`/`prod` GitHub Environments. GitHub Pages reports are public and may disclose dependency and vulnerability details.

## `go.mod`

[`apps/SkillPulse/backend/go.mod`](apps/SkillPulse/backend/go.mod) is Go's module manifest. It identifies the module path (`github.com/trainwithshubham/skillpulse`), specifies the Go version (`1.26`), and lists direct dependencies such as Gin and the MySQL driver. There is currently no `go.sum` in the checkout. Run `go mod tidy` to resolve dependencies and generate `go.sum`, which contains dependency checksums, then commit it so local, CI, and Docker builds use a reproducible dependency graph.

The API health endpoint is `/health`. Its database settings are `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME`.

## Next Production Steps

1. Move Terraform state to encrypted, versioned S3 with locking and remove any committed state from repository history if it exposes sensitive details.
2. For a production topology, migrate from the single k3s EC2 host to EKS with managed node groups; add private application subnets, NAT/VPC endpoints, and the AWS Load Balancer Controller/ALB.
3. Add resource requests/limits, rollout smoke tests, protected environment approvals, and Prometheus/Grafana with persistence and restricted access.
4. Publish security reports only after deciding they may be public.

## Local Checks

```bash
cd apps/SkillPulse/backend
go mod tidy
go test ./...
go vet ./...
cd ../../..
docker build -t skillpulse-backend apps/SkillPulse/backend
docker build -f apps/SkillPulse/Dockerfile.frontend -t skillpulse-frontend apps/SkillPulse
helm lint helm/three-tier
helm template three-tier helm/three-tier --namespace three-tier
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```
