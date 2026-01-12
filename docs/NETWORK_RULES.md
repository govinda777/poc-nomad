# Network Rules

The simulation uses `iptables` and `tc` (Traffic Control) to enforce rules.

## Firewall
-   **Block:** Port 4646 (Nomad RPC) between clouds to simulate management plane isolation.
-   **Allow:** Port 8080 (API) for cross-cluster calls (if implemented).

## VPN Simulation
-   Docker networks `aws-network` (172.20.0.0/16) and `gcp-network` (172.21.0.0/16).
-   `vpn_up.sh`: Connects networks / Flushes drop rules.
-   `vpn_down.sh`: Adds `DROP` rules for cross-subnet traffic.

## Latency
-   `tc qdisc add ... netem delay 200ms`: Adds 200ms round-trip latency.
