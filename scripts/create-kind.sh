#!/usr/bin/env bash
set -euo pipefail
if ! kind get clusters | grep -q '^movie-db$'; then
  kind create cluster --config kind/cluster.yaml
fi
kubectl wait --for=condition=Ready nodes --all --timeout=180s
echo "Kind cluster 'movie-db' is ready."
