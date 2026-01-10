#!/bin/bash
# VPN DOWN: Sever the connection

echo "Severing VPN (disconnecting networks)..."

# Disconnect cross-links
docker network disconnect app_gcp-network postgres-aws-primary || true
docker network disconnect app_gcp-network api-aws || true
docker network disconnect app_aws-network api-gcp || true

echo "VPN Down. Clouds are isolated."
