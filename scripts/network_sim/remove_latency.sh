#!/bin/bash
docker exec api-aws tc qdisc del dev eth0 root
docker exec api-gcp tc qdisc del dev eth0 root
echo "Latency Removed"
