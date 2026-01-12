#!/bin/bash
# VPN UP - Allow communication
docker network connect aws-network gcp-network 2>/dev/null || true
# Alternatively, if using iptables within containers:
docker exec localstack-aws iptables -F
docker exec localstack-gcp iptables -F
echo "VPN UP"
