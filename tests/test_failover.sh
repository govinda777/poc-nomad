#!/bin/bash
echo "Testing Failover..."

./database/scripts/failover.sh

echo "Writing to new Primary (GCP)..."
curl -X POST http://localhost:8082/orders -d '{"item":"after_failover", "qty":1}' -H "Content-Type: application/json"

echo "Verifying..."
curl http://localhost:8082/orders
