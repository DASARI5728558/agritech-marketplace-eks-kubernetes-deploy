# agritech-marketplace-eks-kubernetes-deploy

End-to-end automated deployment of the AgriTech Marketplace (2-tier: Spring
Boot backend + Nginx-served frontend) to Amazon EKS, using Terraform, Helm,
and GitHub Actions.

## Structure

```
agritech-marketplace-eks-kubernetes-deploy/
├── app/
│   ├── backend/            # Spring Boot 3 REST API (Java 17)
│   └── frontend/           # Static HTML/CSS/JS + Nginx
├── terraform/
│   ├── modules/             # vpc, eks, ecr, rds, route53
│   └── envs/{dev,prod}/     # environment-specific root modules
├── k8s/                     # raw manifests: namespaces, secret template, ingress notes
├── helm/agritech-marketplace/
│   ├── Chart.yaml
│   ├── values-dev.yaml / values-prod.yaml
│   └── templates/
├── .github/workflows/deploy.yml   # CI/CD: test → build → push to ECR → deploy to EKS
├── scripts/                  # build-and-push.sh, deploy.sh, setup-github-oidc.sh
└── docs/                     # architecture.md, deployment-guide.md
```

## Quick start

See [`docs/deployment-guide.md`](docs/deployment-guide.md) for full step-by-step
instructions, and [`docs/architecture.md`](docs/architecture.md) for how the
pieces fit together.

```bash
# 1. Provision infra
cd terraform/envs/dev && terraform init && terraform apply

# 2. Build & push images
./scripts/build-and-push.sh dev v1

# 3. Deploy
./scripts/deploy.sh dev v1
```

## CI/CD

`.github/workflows/deploy.yml` runs on every push:
- `develop` branch → deploys to **dev**
- `main` branch → deploys to **prod**
- or trigger manually via the Actions tab (`workflow_dispatch`)

Required GitHub secrets/variables — see `docs/deployment-guide.md` step 7.
