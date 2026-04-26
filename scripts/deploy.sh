#!/bin/bash

set -e  # Stop if there's an error

KEY_PATH=$1
EC2_IP=$2
REMOTE_USER="ubuntu"
DEST_DIR="/home/ubuntu/wordpress-project"

if [ -z "$KEY_PATH" ] || [ -z "$EC2_IP" ]; then
  echo "Usage: ./deploy.sh <key_path> <ec2_ip>"
  exit 1
fi

echo "Deploying to $EC2_IP..."

# Create Folder 
ssh -i "$KEY_PATH" "$REMOTE_USER@$EC2_IP" "mkdir -p $DEST_DIR"

# Moving Files 
scp -i "$KEY_PATH" -r docker scripts docker-compose.yml .env "$REMOTE_USER@$EC2_IP:$DEST_DIR"

# Execution 
ssh -i "$KEY_PATH" "$REMOTE_USER@$EC2_IP" << EOF
  cd $DEST_DIR
  docker compose down
  docker compose up -d
EOF

echo "Deployment done: http://$EC2_IP"
