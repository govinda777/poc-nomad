# Problems & Solutions

This document details the specific Multi-Cloud challenges addressed by this POC.

## 1. Infrastructure & Connectivity

### Problem
Connecting two disparate cloud environments (AWS and GCP) with low latency and high security is difficult.
- **Challenges:** VPN setup, overlapping IP spaces (avoided here), firewall rules, packet loss.

### Solution
- **Simulation:** We use `iptables` and Docker Networks to simulate two distinct VPCs.
- **Control:** `scripts/network_sim/vpn_up.sh` effectively "peers" the networks.
- **Resilience:** The application is designed to retry connections or degrade gracefully (e.g., local-only writes) when the VPN is down.

## 2. Data Replication & Consistency

### Problem
Synchronizing data between active-active regions introduces conflict risks.
- **Latency:** Speed of light limits synchronous replication.
- **Split-Brain:** If networks sever, both sides might accept writes for the same ID.

### Solution
- **Primary-Standby:** We use PostgreSQL Streaming Replication for the data layer. This is Active-Passive at the database level, but Active-Active at the API level (APIs exist in both, but one might be read-only for writes).
- **Conflict Resolution:** For the queue/eventual consistency layer, we implement **Last-Write-Wins (LWW)** based on timestamps.
- **Failover:** Automated promotion of the Standby in GCP if AWS fails.

## 3. Distributed Queueing

### Problem
Queues in different regions can diverge.
- **Duplication:** "At-least-once" delivery means consumers might see the same message twice.

### Solution
- **Idempotency:** The consumer uses `ON CONFLICT` database clauses to ensure processing the same message ID multiple times does not corrupt data.

## 4. Multi-Cloud Traffic

### Problem
Routing users to the nearest available DC and handling cross-DC failures.

### Solution
- **Nomad Orchestration:** Deploying identical jobs to `dc=aws` and `dc=gcp`.
- **Service Discovery:** (Simulated) APIs know where the DB is.
- **Observability:** Prometheus federation to see the global state.
