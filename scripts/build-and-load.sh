#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Build backend
docker build -t moviedb-backend:dev "$ROOT/services/backend"

# Load into kind
kind load docker-image moviedb-backend:dev --name movie-db

echo "Images loaded into Kind."
