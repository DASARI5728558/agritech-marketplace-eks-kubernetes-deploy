# Architecture

## Overview

```
                    ┌─────────────────────────────────────────┐
                    │              Amazon EKS                  │
                    │                                           │
   Internet ──────▶ │  Ingress (NGINX) ─┬─▶ frontend Pods (Nginx)│
                    │                   │      │ static site     │
                    │                   │      │ /api/* proxy ───┼──┐
                    │                   └─▶ backend Pods          │  │
                    │                        (Spring Boot)  ◀─────┼──┘
                    └────────────┬──────────────────────────────┘
                                 │
                                 ▼
                        Amazon RDS (MySQL)
```

## Components

| Layer | Technology | Location |
|---|---|---|
| Frontend | Static HTML/CSS/JS served by Nginx | `app/frontend/` |
| Backend | Spring Boot 3 REST API (Java 17) | `app/backend/` |
| Database | Amazon RDS for MySQL 8.0 | provisioned by `terraform/modules/rds` |
| Container registry | Amazon ECR | provisioned by `terraform/modules/ecr` |
| Orchestration | Amazon EKS | provisioned by `terraform/modules/eks` |
| Networking | VPC, public/private subnets, NAT | provisioned by `terraform/modules/vpc` |
| DNS | Route 53 (prod only) | provisioned by `terraform/modules/route53` |
| Deployment | Helm chart | `helm/agritech-marketplace/` |
| CI/CD | GitHub Actions | `.github/workflows/deploy.yml` |

## Request flow

1. Browser hits the Ingress hostname (or Load Balancer DNS name directly).
2. NGINX Ingress routes:
   - `/api/*` → `agritech-backend-svc` (Spring Boot)
   - everything else → `agritech-frontend-svc` (Nginx serving static files)
3. The frontend's own Nginx config also proxies `/api/*` internally to the
   backend Service, so the static site can be served from a single origin.
4. Backend reads/writes to RDS MySQL using credentials from the
   `agritech-db-secret` Kubernetes Secret.

## Environments

Two isolated environments are supported, each with its own VPC, EKS cluster,
RDS instance, and ECR repos:

- **dev** — smaller instance sizes, single-AZ RDS, no Route 53 record
- **prod** — larger instance sizes, Multi-AZ RDS, deletion protection, Route 53 record + TLS

See `terraform/envs/dev` and `terraform/envs/prod`.
