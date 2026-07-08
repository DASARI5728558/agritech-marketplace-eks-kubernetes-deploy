#!/usr/bin/env bash
# Build and push backend + frontend Docker images to Amazon ECR.
#
# Usage:
#   ./scripts/build-and-push.sh <environment: dev|prod> <image-tag>
#
# Requires: AWS CLI configured (aws configure), Docker running.

set -euo pipefail

ENVIRONMENT="${1:?Usage: $0 <dev|prod> <image-tag>}"
IMAGE_TAG="${2:?Usage: $0 <dev|prod> <image-tag>}"

AWS_REGION="${AWS_REGION:-ap-south-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

BACKEND_REPO="agritech-${ENVIRONMENT}-agritech-backend"
FRONTEND_REPO="agritech-${ENVIRONMENT}-agritech-frontend"

echo ">> Logging in to ECR (${ECR_REGISTRY})..."
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo ">> Building backend image..."
docker build -t "${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}" \
             -t "${ECR_REGISTRY}/${BACKEND_REPO}:latest" \
             ./app/backend

echo ">> Building frontend image..."
docker build -t "${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}" \
             -t "${ECR_REGISTRY}/${FRONTEND_REPO}:latest" \
             ./app/frontend

echo ">> Pushing images..."
docker push "${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}"
docker push "${ECR_REGISTRY}/${BACKEND_REPO}:latest"
docker push "${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}"
docker push "${ECR_REGISTRY}/${FRONTEND_REPO}:latest"

echo ">> Done. Images pushed to ${ECR_REGISTRY}"
