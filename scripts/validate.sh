#!/bin/bash

KEY_PATH=$1
EC2_IP=$2

if [ -z "$KEY_PATH" ] || [ -z "$EC2_IP" ]; then
  echo "Usage: ./validate.sh <key_path> <ec2_ip>"
  exit 1
fi

echo "Validating deployment..."

# Check containers
ssh -i "$KEY_PATH" ubuntu@"$EC2_IP" << 'EOF'
  echo "---- Docker Containers ----"
  docker ps

  echo "---- Checking Nginx ----"
  docker ps | grep nginx || echo "Nginx not running"

  echo "---- Checking WordPress ----"
  docker ps | grep wordpress || echo "WordPress not running"
EOF

# Check HTTP
STATUS=$(curl -o /dev/null -s -w "%{http_code}" "http://$EC2_IP")

if [ "$STATUS" == "200" ] || [ "$STATUS" == "302" ]; then
  echo "Website is up (HTTP $STATUS)"
else
  echo "Website failed (HTTP $STATUS)"
fi
