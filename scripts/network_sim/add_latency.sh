#!/bin/bash
# Add latency using TC (Traffic Control)
# Requires NET_ADMIN capability

LATENCY="200ms"
JITTER="20ms"
LOSS="5%"

echo "Adding network degradation: ${LATENCY} ±${JITTER}, ${LOSS} loss..."

# Apply to AWS API
docker exec --privileged api-aws tc qdisc add dev eth0 root netem delay $LATENCY $JITTER loss $LOSS || \
docker exec --privileged api-aws tc qdisc change dev eth0 root netem delay $LATENCY $JITTER loss $LOSS

# Apply to GCP API
docker exec --privileged api-gcp tc qdisc add dev eth0 root netem delay $LATENCY $JITTER loss $LOSS || \
docker exec --privileged api-gcp tc qdisc change dev eth0 root netem delay $LATENCY $JITTER loss $LOSS

echo "Latency applied."
