#!/bin/bash

# --- 1. Variables Definition ---
# These are positional parameters. 
# $1 refers to the first argument (SSH Key), $2 refers to the second (EC2 IP).
KEY_PATH=$1
EC2_IP=$2
REMOTE_USER="ubuntu"
DEST_DIR="/home/ubuntu/wordpress-project"

# --- 2. Input Validation ---
# Check if the user provided both arguments. -z means "if string is empty"
if [ -z "$KEY_PATH" ] || [ -z "$EC2_IP" ]; then
    echo "❌ Error: Missing arguments."
    echo "Usage: ./deploy.sh <path_to_key> <public_ip>"
    exit 1
fi

echo "🚀 Starting deployment to $EC2_IP..."

# --- 3. Remote Directory Setup ---
# Connect via SSH to create the project folder if it doesn't exist
ssh -i "$KEY_PATH" "$REMOTE_USER@$EC2_IP" "mkdir -p $DEST_DIR"

# --- 4. File Transfer (SCP) ---
# Copying docker-compose.yml, .env, and the nginx directory to the EC2 instance.
# The -r flag is for "recursive" to copy the entire nginx folder.
echo "📦 Uploading configuration files..."
scp -i "$KEY_PATH" docker-compose.yml .env -r nginx/ "$REMOTE_USER@$EC2_IP:$DEST_DIR"

# --- 5. Remote Execution ---
# Using a "Here Document" (<< 'EOF') to run multiple commands on the server.
echo "🛠️ Booting up the containers..."
ssh -i "$KEY_PATH" "$REMOTE_USER@$EC2_IP" << EOF
    cd $DEST_DIR
    # Stop and remove existing containers to ensure a clean start
    sudo docker compose down
    # Start the stack in detached mode
    sudo docker compose up -d
    echo "✅ Docker stack is active!"
EOF

# --- 6. Final Output ---
echo "------------------------------------------------"
echo "🌐 Deployment Complete!"
echo "Visit your site at: http://$EC2_IP"
echo "------------------------------------------------"
