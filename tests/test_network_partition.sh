#!/bin/bash
echo "Testing Network Partition..."

./scripts/network_sim/vpn_down.sh
echo "Partition active. Writing to isolated clouds..."

curl -X POST http://localhost:8081/orders -d '{"item":"isolated_aws", "qty":1}' -H "Content-Type: application/json"
curl -X POST http://localhost:8082/orders -d '{"item":"isolated_gcp", "qty":1}' -H "Content-Type: application/json"

echo "Restoring Network..."
./scripts/network_sim/vpn_up.sh

echo "Verifying eventual consistency..."
sleep 5
curl http://localhost:8081/orders
curl http://localhost:8082/orders
