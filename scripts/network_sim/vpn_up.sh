#!/bin/bash
# VPN UP: Allow traffic between AWS (172.20.0.0/16) and GCP (172.21.0.0/16)

# We need to find the containers acting as "routers" or just open it up on the bridge network level if possible.
# But Docker networks are isolated.
# The `docker-compose.yml` doesn't explicitly bridge them.
# To simulate VPN, we can just rely on Docker's inter-network routing IF we attached containers to both.
# BUT we didn't. We put them in separate networks.
# So they CANNOT talk unless we attach a router container or `docker network connect`.

# STRATEGY CHANGE:
# To simulate a controllable VPN, we will attach the "Nomad Servers" or "API nodes" to BOTH networks?
# OR we use a `router` container.
#
# Simpler approach for LocalStack simulation:
# Use `docker network connect` to bridge specific nodes when "VPN is UP".
# When "VPN is DOWN", `docker network disconnect`.

# Let's try to connect the API nodes to the other network so they can talk cross-cloud.
# And the Postgres nodes so replication works.

echo "Establishing VPN (connecting networks)..."

# Connect AWS Postgres to GCP network (so GCP Standby can pull WAL)
docker network connect app_gcp-network postgres-aws-primary || true

# Connect AWS API to GCP network (for cross-region calls if needed)
docker network connect app_gcp-network api-aws || true

# Connect GCP API to AWS network
docker network connect app_aws-network api-gcp || true

echo "VPN Established."
