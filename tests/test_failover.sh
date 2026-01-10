#!/bin/bash
set -e

# Test 3: Failover
# 1. Verify Repl status
# 2. Kill AWS Postgres
# 3. Promote GCP Postgres
# 4. Verify Writes to GCP work

AWS_API="http://localhost:8081"
GCP_API="http://localhost:8082"
ID_FAILOVER=$RANDOM

echo "--- STARTING FAILOVER TEST ---"

echo "Step 1: Simulating AWS Primary Failure (Stopping Container)..."
docker stop postgres-aws-primary

echo "Step 2: Promoting GCP Standby..."
./database/scripts/failover.sh
sleep 2

echo "Step 3: Writing to GCP (New Primary)..."
# The API for GCP is pointing to 'postgres-gcp-standby' hostname.
# Since we promoted it, it should now accept writes.
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $GCP_API/orders -d "{\"id\": $ID_FAILOVER, \"item\": \"failover-item\", \"qty\": 1}")

if [ "$HTTP_CODE" == "201" ]; then
    echo "SUCCESS: Write accepted by promoted GCP Primary."
else
    echo "FAILURE: GCP Primary rejected write with code $HTTP_CODE"
    exit 1
fi

echo "Failover Test Complete."
