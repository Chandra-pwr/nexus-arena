#!/usr/bin/env bash
# Usage: ./scripts/bootstrap.sh dev   (needs aws cli, terraform, kubectl, helm)
set -euo pipefail
ENV=${1:-dev}
( cd terraform/live/bootstrap/aws-state && terraform init && terraform apply -auto-approve )
for l in 01-network 02-eks 03-addons; do
  ( cd terraform/live/$ENV/aws/$l && terraform init && terraform apply -auto-approve )
done
aws eks update-kubeconfig --name nexus-$ENV --region ap-south-1
kubectl apply -f k8s/cluster-issuer.yaml
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f helm/values/monitoring-aws.yaml
kubectl apply -f monitoring/alerts/
