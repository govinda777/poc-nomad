#!/bin/bash
# VPN DOWN - Block communication
# In docker, blocking traffic between bridge networks is tricky without modifying host iptables
# or using a router container.
# Simplified approach: Use internal iptables in the "gateway" or the containers themselves if they have capabilities.
# The prompt suggested iptables inside the containers.

docker exec api-aws iptables -A INPUT -s 172.21.0.0/16 -j DROP
docker exec api-gcp iptables -A INPUT -s 172.20.0.0/16 -j DROP
echo "VPN DOWN"
