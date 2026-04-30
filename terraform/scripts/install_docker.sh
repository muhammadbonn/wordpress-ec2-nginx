#!/bin/bash

# --- Docker & Docker Compose Installation Script ---

# 1. Update the package database to ensure we have the latest info
sudo apt-get update -y

# 2. Install prerequisite packages for HTTPS repositories
sudo apt-get install -y ca-certificates curl gnupg

# 3. Add Docker’s official GPG key for package verification (Added --yes to overwrite if exists)
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Set up the Docker repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine, CLI, and the Compose plugin
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Enable Docker to run without sudo by adding the current user to the docker group
sudo usermod -aG docker $USER

# 7. Apply group changes without logout and run deployment commands
newgrp docker <<EONG
# Verify installation
docker --version
docker compose version

# --- THE FIX: Clean up old containers and networks ---
echo "Cleaning up old containers..."
docker compose down || true

# --- Deploy the new containers ---
echo "Deploying new WordPress stack..."
docker compose up -d
EONG
