#!/bin/bash
set -e

# Test 2: Network Partition
AWS_API="http://localhost:8081"
GCP_API="http://localhost:8082"
ID=$RANDOM

echo "--- STARTING PARTITION TEST ---"
./scripts/network_sim/vpn_down.sh

echo "Writing Order $ID to AWS (Isolated)..."
curl -X POST $AWS_API/orders -d "{\"id\": $ID, \"item\": \"partition-test\", \"qty\": 1}"

sleep 1
echo "Checking GCP (Should NOT have data)..."
CODE=$(curl -o /dev/null -s -w "%{http_code}" $GCP_API/orders/$ID)
if [ "$CODE" == "200" ]; then
  echo "FAILURE: Data leaked to GCP despite partition!"
else
  echo "SUCCESS: Data not found in GCP (Code: $CODE)"
fi

echo "Healing Network..."
./scripts/network_sim/vpn_up.sh
sleep 5 # Allow replication catch-up

echo "Checking GCP (Should NOW have data)..."
CODE=$(curl -o /dev/null -s -w "%{http_code}" $GCP_API/orders/$ID)
if [ "$CODE" == "200" ]; then
  echo "SUCCESS: Data replicated after healing."
else
  echo "FAILURE: Data still missing in GCP."
fi
