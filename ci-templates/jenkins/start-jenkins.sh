#!/bin/bash

# Simple Jenkins Docker startup script
# Creates a Jenkins container with persistent data volume

set -e

JENKINS_HOME_DIR="$HOME/jenkins_home"
CONTAINER_NAME="jenkins-local"
JENKINS_PORT="8080"

echo "Starting Jenkins with Docker..."

# Create Jenkins home directory if it doesn't exist
mkdir -p "$JENKINS_HOME_DIR"

# Stop and remove existing container if running
if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping existing Jenkins container..."
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
fi

# Start Jenkins container
docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$JENKINS_PORT:8080" \
    -p 50000:50000 \
    -v "$JENKINS_HOME_DIR:/var/jenkins_home" \
    jenkins/jenkins:lts

echo "Jenkins is starting up..."
echo "Access Jenkins at: http://localhost:$JENKINS_PORT"
echo "Jenkins home directory: $JENKINS_HOME_DIR"

# Wait for Jenkins to start and show initial admin password
echo "Waiting for Jenkins to initialize..."
sleep 10

if docker exec "$CONTAINER_NAME" test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
    echo ""
    echo "Initial admin password:"
    docker exec "$CONTAINER_NAME" cat /var/jenkins_home/secrets/initialAdminPassword
    echo ""
else
    echo "Jenkins is still starting up. Check the password later with:"
    echo "docker exec $CONTAINER_NAME cat /var/jenkins_home/secrets/initialAdminPassword"
fi



cd87e585e08c4300b3d136f5a8049e01