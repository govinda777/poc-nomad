# Network Rules & Firewall Configuration

In this POC, we simulate the following network security rules using Docker/Iptables.

## Simulated Topography

- **AWS VPC:** `172.20.0.0/16`
- **GCP VPC:** `172.21.0.0/16`

## Firewall Rules (Security Groups)

### 1. Nomad Protocol
- **Port:** `4646` (RPC), `4647` (Serf)
- **Rule:** Allow traffic between AWS and GCP servers for federation.
- **Simulation:** `scripts/network_sim/vpn_up.sh` enables this flow.

### 2. Database Replication
- **Port:** `5432` (PostgreSQL)
- **Rule:** Allow GCP Standby (`172.21.1.100`) to connect to AWS Primary (`172.20.1.100`).
- **Constraint:** Access limited to replication user `poc`.

### 3. API Traffic
- **Port:** `8080`
- **Rule:** Public access allowed. Internal cross-DC calls allowed via VPN.

## Latency Simulation

To mimic real world conditions, we apply `tc` (Traffic Control) rules:
- **Base Latency:** 200ms
- **Jitter:** ±20ms
- **Packet Loss:** 5%

This ensures our tests (`test_replication_lag.sh`) validate the system's behavior under stress.
