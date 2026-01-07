#!/bin/bash
# Script to push Docker images to GitHub Container Registry
# Usage: ./push-images-to-ghcr.sh

set -e

# GitHub Container Registry settings
REGISTRY="ghcr.io"
OWNER="mxcube"

# Images to push
IMAGES=(
    "arinax:MD:arinax-md:latest"
    "flex-server:latest:flex-server-simulation:20241212"
)

echo "=== Pushing Docker images to GitHub Container Registry ==="
echo ""

# Check if logged in to ghcr.io
if ! grep -q "ghcr.io" ~/.docker/config.json 2>/dev/null; then
    echo "⚠️  You need to login to GitHub Container Registry first:"
    echo "   echo \$GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin"
    echo ""
    echo "   To create a token: https://github.com/settings/tokens/new"
    echo "   Required scopes: write:packages, read:packages, delete:packages"
    exit 1
fi

for img_spec in "${IMAGES[@]}"; do
    IFS=':' read -r local_name local_tag remote_name remote_tag <<< "$img_spec"
    
    local_image="${local_name}:${local_tag}"
    remote_image="${REGISTRY}/${OWNER}/${remote_name}:${remote_tag}"
    
    echo "📦 Processing: $local_image -> $remote_image"
    
    # Check if local image exists
    if ! docker image inspect "$local_image" &>/dev/null; then
        echo "❌ Error: Local image '$local_image' not found"
        exit 1
    fi
    
    # Tag the image
    echo "   Tagging..."
    docker tag "$local_image" "$remote_image"
    
    # Push the image
    echo "   Pushing to registry..."
    docker push "$remote_image"
    
    echo "   ✅ Done"
    echo ""
done

echo "=== All images pushed successfully! ==="
echo ""
echo "Images are now available at:"
for img_spec in "${IMAGES[@]}"; do
    IFS=':' read -r local_name local_tag remote_name remote_tag <<< "$img_spec"
    echo "  - ${REGISTRY}/${OWNER}/${remote_name}:${remote_tag}"
done
