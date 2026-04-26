#!/bin/bash

# --- 1. Arguments ---
KEY_PATH=$1
EC2_IP=$2

if [ -z "$KEY_PATH" ] || [ -z "$EC2_IP" ]; then
    echo "Usage: ./validate.sh <key_path> <ec2_ip>"
    exit 1
fi

echo "🔍 Starting Validation for $EC2_IP..."

# --- 2. Remote Health Checks ---
ssh -i "$KEY_PATH" ubuntu@"$EC2_IP" << 'EOF'
    echo "--- 📦 Container Status Check ---"
    # Get the exact container name that contains "db"
    DB_CONTAINER=$(sudo docker ps --filter "name=db" --format "{{.Names}}" | head -n 1)
    
    if [ -z "$DB_CONTAINER" ]; then
        echo "❌ ERROR: Database container not found!"
        exit 1
    fi

    echo "Found DB Container: $DB_CONTAINER"
    
    # Check Database Health using the dynamic name
    DB_STATUS=$(sudo docker inspect --format='{{json .State.Health.Status}}' "$DB_CONTAINER")
    echo "Database Health Status: $DB_STATUS"

    if [ "$DB_STATUS" != "\"healthy\"" ]; then
        echo "❌ ERROR: Database is not healthy yet! Current status: $DB_STATUS"
        exit 1
    fi
EOF

# --- 3. HTTP Response Check (From your local machine) ---
echo "--- 🌐 Web Server Response Check ---"
# Check if the public IP returns a 200 OK or 302 Found (WP Setup Redirect)
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" "http://$EC2_IP")

if [ "$HTTP_STATUS" == "200" ] || [ "$HTTP_STATUS" == "302" ]; then
    echo "✅ SUCCESS: Website is accessible (HTTP $HTTP_STATUS)"
else
    echo "❌ ERROR: Website returned HTTP $HTTP_STATUS. Check your Security Groups!"
fi

echo "------------------------------------------------"
echo "Validation Complete!"
