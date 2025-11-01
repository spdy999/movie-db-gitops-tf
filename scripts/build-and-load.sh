#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

IMAGE_NAME_BE="moviedb-backend:dev"
IMAGE_NAME_FE="moviedb-frontend:dev"
IMAGE_TAR_BE="moviedb-backend.tar"
IMAGE_TAR_FE="moviedb-frontend.tar"

echo "📦 Building backend image with Podman..."
podman build -t ${IMAGE_NAME_BE} "${ROOT}/services/backend"

echo "📦 Building frontend image with Podman..."
podman build -t ${IMAGE_NAME_FE} "${ROOT}/services/frontend-react"

echo "📤 Exporting image to tar..."
podman save -o "${IMAGE_TAR_BE}" ${IMAGE_NAME_BE}
podman save -o "${IMAGE_TAR_FE}" ${IMAGE_NAME_FE}

echo "📥 Loading image into Kind..."
kind load image-archive "${IMAGE_TAR_BE}" --name movie-db
kind load image-archive "${IMAGE_TAR_FE}" --name movie-db

echo "✅ Image ${IMAGE_NAME_BE} loaded into Kind."
echo "✅ Image ${IMAGE_NAME_FE} loaded into Kind."
# echo "Cleanup temporary tar..."
# rm -f "${IMAGE_TAR}"
