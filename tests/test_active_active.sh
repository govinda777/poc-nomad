#!/bin/bash
echo "Testing Active-Active Traffic..."

# Simple smoke test
for i in {1..5}; do
   curl -X POST http://localhost:8081/orders -d '{"item":"item'$i'", "qty":1}' -H "Content-Type: application/json"
   curl -X POST http://localhost:8082/orders -d '{"item":"item_gcp_'$i'", "qty":1}' -H "Content-Type: application/json"
done

echo "Check data..."
curl http://localhost:8081/orders
curl http://localhost:8082/orders
