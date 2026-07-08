# Deployment Guide

Follow these steps in order for a first-time deployment to AWS.

## Prerequisites

- AWS CLI installed and configured (`aws configure`)
- Terraform >= 1.6
- kubectl
- Helm >= 3.15
- Docker

## 1. Provision AWS infrastructure

```bash
cd terraform/envs/dev
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: set mysql_admin_password
terraform init
terraform apply
```

This creates the VPC, EKS cluster, ECR repositories, and RDS MySQL instance.

## 2. Point kubectl at the new cluster

```bash
aws eks update-kubeconfig --region ap-south-1 --name agritech-dev-eks
kubectl get nodes    # sanity check
```

## 3. Create required namespaces and secrets

```bash
kubectl apply -f k8s/namespace.yaml

kubectl create secret generic agritech-db-secret \
  --from-literal=username=agritech_admin \
  --from-literal=password='<your-mysql-password-from-step-1>' \
  -n agritech-dev
```

## 4. Install the NGINX Ingress Controller (one-time per cluster)

See `k8s/README.md` for the full command. Short version:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer
```

## 5. Build and push images

Either run locally:
```bash
./scripts/build-and-push.sh dev v1
```
...or let GitHub Actions do it automatically on push (see step 7).

## 6. Deploy with Helm

```bash
./scripts/deploy.sh dev v1
```

## 7. Set up CI/CD (optional but recommended)

```bash
./scripts/setup-github-oidc.sh <your-github-username> <your-repo-name>
```
Copy the printed Role ARN into GitHub:
**Settings → Secrets and variables → Actions**
- Secret: `AWS_ROLE_ARN`
- Variables: `AWS_REGION`, `ECR_REGISTRY`

From then on, pushing to `develop` deploys to dev, and pushing to `main`
deploys to prod automatically via `.github/workflows/deploy.yml`.

## 8. Verify

```bash
kubectl get pods -n agritech-dev
kubectl get ingress -n agritech-dev
```

Open the Ingress host or Load Balancer DNS name in a browser.

## Repeating for prod

Same steps, but use `terraform/envs/prod`, namespace `agritech-prod`, and
`values-prod.yaml`. Prod also provisions a Route 53 DNS record — see
`terraform/envs/prod/terraform.tfvars.example` for the extra variables
(`dns_zone_name`, `load_balancer_dns_name`).
