#!/bin/bash
# Promote Standby to Primary
docker exec postgres-gcp-standby pg_ctl promote -D /var/lib/postgresql/data
echo "GCP Database promoted to Primary!"
