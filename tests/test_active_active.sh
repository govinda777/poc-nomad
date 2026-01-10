#!/bin/bash
set -e

# Test 1: Active-Active
# Send requests to both APIs (via localhost ports) and verify data presence

# AWS is on port 8081
# GCP is on port 8082
AWS_API="http://localhost:8081"
GCP_API="http://localhost:8082"

echo "Checking Health..."
curl -f -s $AWS_API/health || echo "AWS API Down"
curl -f -s $GCP_API/health || echo "GCP API Down"

echo "Writing to AWS..."
ID=$RANDOM
curl -X POST $AWS_API/orders -d "{\"id\": $ID, \"item\": \"test-aws\", \"qty\": 1}"
echo "Written Order $ID to AWS"

# Allow for replication (if async)
sleep 2

echo "Reading from GCP..."
CODE=$(curl -o /dev/null -s -w "%{http_code}" $GCP_API/orders/$ID)
if [ "$CODE" == "200" ]; then
  echo "SUCCESS: Order $ID found in GCP."
else
  echo "FAILURE: Order $ID not found in GCP (Code: $CODE)"
fi
