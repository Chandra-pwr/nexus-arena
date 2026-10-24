#!/usr/bin/env bash
# Usage: ./scripts/deploy.sh aws [image-tag]
set -euo pipefail
CLOUD=${1:-aws}; TAG=${2:-latest}
for c in frontend auth-service matchmaking-service game-state-service inventory-service leaderboard-service chat-service; do
  helm dependency update helm/$c
  helm upgrade --install $c helm/$c -f helm/values/values-$CLOUD.yaml --set image.tag=$TAG
done
kubectl apply -f k8s/network-policies/
