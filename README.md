# Movie DB — Fullstack GitOps (Kind + Terraform + ArgoCD + Helm)

This repo bootstraps a **Kind** cluster with **Terraform**, installs **ArgoCD** (via Helm), and declares an **ArgoCD Application** that syncs a **Helm chart** for a fullstack app:
- **PostgreSQL** (StatefulSet-like; `emptyDir` for local)
- **Backend**: FastAPI (`/api/movies`) connecting to Postgres
- **Frontend**: Nginx serving a tiny SPA, proxying `/api` → backend
- 100% **GitOps/IaC**: Terraform manages ArgoCD + Application; ArgoCD syncs Helm

> For simplicity, Postgres uses `emptyDir`. Swap to a PVC + StorageClass for real persistence.

---

## Prereqs

- Docker
- kind
- kubectl
- terraform >= 1.5
- helm plugin in terraform provider (auto-installed)

macOS install examples:
```bash
brew install kind kubectl terraform
```

---

## Quickstart

```bash
# 1) Create Kind cluster
./scripts/create-kind.sh

# 2) Build images & load into Kind (tags match Helm values)
./scripts/build-and-load.sh

# 3) Terraform bootstrap (installs ArgoCD + Application)
cd infra
terraform init
terraform apply -auto-approve

# 4) Open ArgoCD UI (optional)
kubectl -n argocd port-forward svc/argocd-server 8080:443
# admin / $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)

# 5) Access frontend
kubectl -n movie-db port-forward svc/frontend 8081:80
# visit http://localhost:8081
```

**Make a GitOps change:** edit files under `apps/movie-db`, commit, and ArgoCD will reconcile.

---

## Repo Layout

```
kind/
  cluster.yaml
infra/              # Terraform (installs ArgoCD and applies Argo App CR)
  main.tf
  providers.tf
  variables.tf
  argocd_app.yaml   # rendered via kubectl provider
apps/
  movie-db/         # Helm chart (db + backend + frontend)
    Chart.yaml
    values.yaml
    templates/...
services/
  backend/          # FastAPI app + Dockerfile
  frontend/         # static assets (Nginx serves from ConfigMap)
scripts/
  create-kind.sh
  build-and-load.sh
```

---

## Notes

- Images are local: `moviedb-backend:dev` and `nginx:alpine` (from Docker Hub). You can push to a registry and update `values.yaml` if desired.
- To persist Postgres: install a local provisioner (e.g., `rancher/local-path-provisioner`) and change the Helm template to use a PVC.
