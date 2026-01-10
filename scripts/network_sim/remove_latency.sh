#!/bin/bash
# Remove latency

echo "Removing network degradation..."

docker exec --privileged api-aws tc qdisc del dev eth0 root || true
docker exec --privileged api-gcp tc qdisc del dev eth0 root || true

echo "Network normal."
