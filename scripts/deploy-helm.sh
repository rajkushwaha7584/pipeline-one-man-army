#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="three-tier"
RELEASE_NAME="three-tier"
CHART_PATH="./helm/three-tier"
BACKEND_IMAGE="one-man-army-backend"
FRONTEND_IMAGE="one-man-army-frontend"
IMAGE_TAG="latest"
DB_SECRET_NAME="app-db"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --namespace)
      NAMESPACE="$2"
      shift 2
      ;;
    --release)
      RELEASE_NAME="$2"
      shift 2
      ;;
    --chart)
      CHART_PATH="$2"
      shift 2
      ;;
    --backend-image)
      BACKEND_IMAGE="$2"
      shift 2
      ;;
    --frontend-image)
      FRONTEND_IMAGE="$2"
      shift 2
      ;;
    --tag)
      IMAGE_TAG="$2"
      shift 2
      ;;
    --db-secret)
      DB_SECRET_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --set namespace="$NAMESPACE" \
  --set images.backend="$BACKEND_IMAGE" \
  --set images.frontend="$FRONTEND_IMAGE" \
  --set images.tag="$IMAGE_TAG" \
  --set mysql.existingSecret="$DB_SECRET_NAME" \
  --wait --timeout 10m
