#!/bin/bash
# --- Validation Script for WordPress Stack ---

KEY_PATH=$1
EC2_IP=$2

if [ -z "$KEY_PATH" ] || [ -z "$EC2_IP" ]; then
    echo "Usage: ./validate.sh <key_path> <ec2_ip>"
    exit 1
fi

echo "🔍 Validating deployment at $EC2_IP..."

# Check Docker containers status via SSH
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@"$EC2_IP" << 'EOF'
    echo "--- Active Docker Containers ---"
    sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

    echo "--- Health Checks ---"
    sudo docker ps | grep nginx && echo "✔ Nginx is running" || echo "✘ Nginx is DOWN"
    sudo docker ps | grep wordpress && echo "✔ WordPress is running" || echo "✘ WordPress is DOWN"
    sudo docker ps | grep db && echo "✔ Database is running" || echo "✘ Database is DOWN"
EOF

# Give WordPress time to initialize and establish DB connection
echo "⏳ Waiting 15 seconds for WordPress to fully initialize..."
sleep 15

# Perform a local HTTP health check
echo "--- Web Service Check ---"
STATUS=$(curl -o /dev/null -s -w "%{http_code}" "http://$EC2_IP")

if [[ "$STATUS" == "200" || "$STATUS" == "302" ]]; then
    echo "⭐ SUCCESS: Website is accessible (HTTP $STATUS)"
else
    echo "🚨 FAILURE: Website returned HTTP $STATUS"
    exit 1
fi
