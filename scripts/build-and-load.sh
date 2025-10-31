#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

IMAGE_NAME="moviedb-backend:dev"
IMAGE_TAR="/tmp/moviedb-backend.tar"

echo "📦 Building backend image with Podman..."
podman build -t ${IMAGE_NAME} "${ROOT}/services/backend"

echo "📤 Exporting image to tar..."
podman save -o "${IMAGE_TAR}" ${IMAGE_NAME}

echo "📥 Loading image into Kind..."
kind load image-archive "${IMAGE_TAR}" --name movie-db

echo "✅ Image ${IMAGE_NAME} loaded into Kind."
echo "Cleanup temporary tar..."
rm -f "${IMAGE_TAR}"
