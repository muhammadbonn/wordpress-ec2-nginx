#!/bin/bash
# --- Deployment Script for WordPress Stack ---

set -e # Exit immediately if a command exits with a non-zero status

KEY_PATH=$1
EC2_IP=$2
REMOTE_USER="ubuntu"
DEST_DIR="/home/ubuntu/wordpress-project"

# Ensure required arguments are provided
if [ -z "$KEY_PATH" ] || [ -z "$EC2_IP" ]; then
    echo "Usage: ./deploy.sh <key_path> <ec2_ip>"
    exit 1
fi

echo "🚀 Deploying to $EC2_IP..."

# Create destination directory on the remote server
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" "$REMOTE_USER@$EC2_IP" "mkdir -p $DEST_DIR"

# Copy Docker configs, Nginx configs, Compose file, and Environment variables
# Added 'docker' folder to match your new structure
scp -i "$KEY_PATH" -r docker docker-compose.yml .env "$REMOTE_USER@$EC2_IP:$DEST_DIR"

# Execute Docker Compose commands on the remote server
ssh -i "$KEY_PATH" "$REMOTE_USER@$EC2_IP" << EOF
    cd $DEST_DIR
    # Pull latest images and restart containers
    sudo docker compose down
    sudo docker compose up -d --build
EOF

echo "✅ Deployment successful: http://$EC2_IP"
