#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Cleaning up test harness...${NC}"

# Stop and remove containers, networks, volumes, and images created by docker-compose
echo "Stopping and removing Docker Compose resources..."
docker-compose down -v

# Remove any dangling containers that might be related
echo "Checking for any remaining containers..."
if docker ps -a | grep -q 'test-harness'; then
    echo "Found remaining test-harness containers. Removing..."
    docker ps -a | grep 'test-harness' | awk '{print $1}' | xargs -r docker rm -f
fi

# Clean up any test-related networks
echo "Cleaning up networks..."
docker network ls | grep 'test-harness' | awk '{print $1}' | xargs -r docker network rm

# Clean up any test-related volumes
echo "Cleaning up volumes..."
docker volume ls | grep 'test-harness' | awk '{print $2}' | xargs -r docker volume rm

# Verify cleanup
echo -e "\n${GREEN}Cleanup complete!${NC}"
echo "Current running containers:"
docker ps

echo -e "\nTo remove the test harness directory, run:"
echo -e "${BLUE}rm -rf test-harness${NC}"