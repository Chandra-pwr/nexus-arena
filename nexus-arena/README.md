# Nexus Arena
Multi-cloud (AWS + Azure) gaming tournament platform: nginx frontend, 6 Go microservices, Helm, Terraform, Prometheus/Grafana.

## Run locally
    docker compose up --build
    open http://localhost:8081

## Deploy to AWS
1. Set a unique bucket name in `terraform/live/bootstrap/aws-state` and every `backend.tf` / remote state block (search CHANGEME).
2. `./scripts/bootstrap.sh dev`
3. Create secrets `nexus/jwt-secret` and `nexus/auth-db-url` in AWS Secrets Manager, install External Secrets Operator, then `kubectl apply -f k8s/external-secrets.yaml`
4. Replace `YOUR_GH_USER` in `helm/*/values.yaml`, then `./scripts/deploy.sh aws latest`

## Status
- Working: frontend, auth-service (Postgres + JWT), Helm (common library chart + 7 charts), AWS Terraform (vpc, eks, rds, addons), CI, k8s manifests, alerts
- Stub: other 5 Go services (in-memory, /healthz + one endpoint each), Azure modules/layers, VPN peering, dev/staging DNS
