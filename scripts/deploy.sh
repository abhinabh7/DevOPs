#!/bin/bash
set -e

echo "Starting deployment..."

# Load environment variables
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | xargs)
  echo "Environment variables loaded"
else
  echo ".env file not found! Copy .env.example to .env"
  exit 1
fi

# Pull latest code
echo "Pulling latest code..."
git pull origin main

# Build and restart containers
echo "Building Docker images..."
docker-compose build --no-cache

echo "Restarting services..."
docker-compose down
docker-compose up -d

# Health check
echo "Running health check..."
sleep 5
curl -f http://localhost/health && echo "App is healthy!" || echo "Health check failed"

echo "Deployment complete!"
