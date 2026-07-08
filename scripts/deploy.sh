#!/usr/bin/env bash
# Deploy the AgriTech Marketplace Helm chart to an EKS cluster.
#
# Usage:
#   ./scripts/deploy.sh <environment: dev|prod> [image-tag]
#
# Requires: AWS CLI, kubectl, Helm 3, cluster already provisioned via Terraform.

set -euo pipefail

ENVIRONMENT="${1:?Usage: $0 <dev|prod> [image-tag]}"
IMAGE_TAG="${2:-latest}"
AWS_REGION="${AWS_REGION:-ap-south-1}"
CLUSTER_NAME="agritech-${ENVIRONMENT}-eks"
NAMESPACE="agritech-${ENVIRONMENT}"

echo ">> Updating kubeconfig for ${CLUSTER_NAME}..."
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

echo ">> Ensuring namespace exists..."
kubectl apply -f k8s/namespace.yaml

echo ">> Checking for DB secret..."
if ! kubectl get secret agritech-db-secret -n "$NAMESPACE" >/dev/null 2>&1; then
  echo "WARNING: agritech-db-secret not found in namespace ${NAMESPACE}."
  echo "Create it first, e.g.:"
  echo "  kubectl create secret generic agritech-db-secret \\"
  echo "    --from-literal=username=agritech_admin \\"
  echo "    --from-literal=password='<password>' \\"
  echo "    -n ${NAMESPACE}"
  exit 1
fi

echo ">> Deploying with Helm (image tag: ${IMAGE_TAG})..."
helm upgrade --install agritech-marketplace ./helm/agritech-marketplace \
  -f "./helm/agritech-marketplace/values-${ENVIRONMENT}.yaml" \
  --set backend.image.tag="${IMAGE_TAG}" \
  --set frontend.image.tag="${IMAGE_TAG}" \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --wait --timeout 5m

echo ">> Verifying rollout..."
kubectl rollout status deployment/agritech-marketplace-backend -n "$NAMESPACE"
kubectl rollout status deployment/agritech-marketplace-frontend -n "$NAMESPACE"

echo ">> Deployment complete. Pods:"
kubectl get pods -n "$NAMESPACE"
