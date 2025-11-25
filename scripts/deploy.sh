#!/bin/bash

set -e  # Exit on error

echo "🚀 Starting deployment..."

# Variables
IMAGE_NAME="devops-lab-api"
VERSION="${1:-latest}"
CONTAINER_NAME="devops-api"

# Stop and remove old container if exists
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
      echo "🛑 Stopping existing container..."
      docker stop $CONTAINER_NAME
      docker rm $CONTAINER_NAME
fi

# Build new image
echo "🔨 Building Docker image..."
docker build -t $IMAGE_NAME:$VERSION .

# Run new container
echo "▶️  Starting container..."
docker run -d -p 5000:5000 --name $CONTAINER_NAME $IMAGE_NAME:$VERSION

# Wait for container to be ready
echo "⏳ Waiting for API to be ready..."
sleep 3

# Health check
echo "🏥 Performing health check..."
RESPONSE=$(curl -s http://localhost:5000/health)

if echo "$RESPONSE" | grep -q "healthy"; then
      echo "✅ Deployment successful!"
      echo "📊 Response: $RESPONSE"
else
      echo "❌ Deployment failed!"
      exit 1
fi
