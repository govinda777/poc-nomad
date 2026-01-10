#!/bin/bash
set -e

# Failover script: Promote GCP Standby to Primary

echo "Promoting GCP Standby to Primary..."
docker exec postgres-gcp-standby pg_ctl promote -D /var/lib/postgresql/data -U poc

echo "GCP is now Primary. Updating App config if necessary (apps should auto-detect or use DNS)."
# In a real scenario, we would update Consul/DNS.
# Here, the 'api-gcp' is already pointing to 'postgres-gcp-standby', so it will just start succeeding in writes.

echo "Failover Complete."
