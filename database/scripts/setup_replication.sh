#!/bin/bash
set -e

# Wait for Primary DB to be ready
echo "Waiting for Primary DB (AWS)..."
until PGPASSWORD=pocpass psql -h postgres-aws-primary -U poc -d pocdb -c '\q'; do
  echo "Primary unavailable - sleeping"
  sleep 1
done

echo "Primary is UP. Creating replication slot..."
PGPASSWORD=pocpass psql -h postgres-aws-primary -U poc -d pocdb -c "SELECT pg_create_physical_replication_slot('gcp_standby_slot');" || true

# Check if Standby is already replicated
# We check if data directory has standby.signal or if we can connect as read-only
if docker exec postgres-gcp-standby test -f /var/lib/postgresql/data/standby.signal; then
    echo "Standby already configured."
    exit 0
fi

echo "Configuring Standby DB (GCP)..."

# 1. Stop the Standby instance
docker stop postgres-gcp-standby

# 2. Clean data directory
echo "Cleaning Standby Data Directory..."
docker run --rm --volumes-from postgres-gcp-standby alpine sh -c "rm -rf /var/lib/postgresql/data/*"

# 3. Run pg_basebackup
# We run a temporary postgres container attached to the SAME network as Primary to pull data, writing to the Standby volume
echo "Running pg_basebackup..."
docker run --rm \
  --network app_aws-network \
  --volumes-from postgres-gcp-standby \
  --env PGPASSWORD=pocpass \
  postgres:15-alpine \
  pg_basebackup -h postgres-aws-primary -D /var/lib/postgresql/data -U poc -Fp -Xs -P -R

# 4. Start Standby
echo "Starting Standby..."
docker start postgres-gcp-standby

# 5. Connect Standby to AWS network so it can stream WAL?
# Wait, pg_basebackup used 'postgres-aws-primary'. The standby needs to resolve that hostname.
# By default, GCP network can't resolve AWS network hostnames unless we bridged them.
# The 'vpn_up.sh' script connects them.
# We must ensure VPN is UP before replication starts.
./scripts/network_sim/vpn_up.sh

echo "Replication Setup Complete."
