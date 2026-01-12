#!/bin/bash
docker exec api-aws tc qdisc add dev eth0 root netem delay 200ms 20ms loss 5%
docker exec api-gcp tc qdisc add dev eth0 root netem delay 200ms 20ms loss 5%
echo "Latency Added"
