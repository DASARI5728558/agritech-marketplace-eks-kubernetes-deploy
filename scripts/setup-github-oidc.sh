#!/usr/bin/env bash
# One-time setup: create an AWS IAM OIDC provider for GitHub Actions and an
# IAM role it can assume (no long-lived AWS keys needed in GitHub secrets).
#
# Usage:
#   ./scripts/setup-github-oidc.sh <github-org-or-user> <github-repo>
#
# Example:
#   ./scripts/setup-github-oidc.sh DASARI5728558 agritech-marketplace-eks-kubernetes-deploy

set -euo pipefail

GH_OWNER="${1:?Usage: $0 <github-owner> <github-repo>}"
GH_REPO="${2:?Usage: $0 <github-owner> <github-repo>}"
ROLE_NAME="github-actions-agritech-role"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo ">> Creating OIDC identity provider for GitHub Actions (if not already present)..."
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  || echo "   (provider likely already exists — continuing)"

cat > /tmp/trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GH_OWNER}/${GH_REPO}:*"
        }
      }
    }
  ]
}
EOF

echo ">> Creating IAM role ${ROLE_NAME}..."
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document file:///tmp/trust-policy.json \
  || echo "   (role likely already exists — continuing)"

echo ">> Attaching permissions..."
aws iam attach-role-policy --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
aws iam attach-role-policy --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)

echo ""
echo ">> Done. Add this as a GitHub Actions secret named AWS_ROLE_ARN:"
echo "   ${ROLE_ARN}"
