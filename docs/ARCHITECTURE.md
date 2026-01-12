# Architecture

## Overview
This Proof of Concept (POC) simulates a Multi-Cloud Active-Active architecture using local tools.

## Components

### 1. Orchestration (Nomad)
- **Datacenter 1 (AWS):** Simulated region handling US traffic.
- **Datacenter 2 (GCP):** Simulated region handling EU traffic.
- **Jobs:** Application services (API, Consumer) are deployed as Nomad jobs.

### 2. Networking (Simulated)
- **LocalStack:** Simulates AWS (port 4566) and GCP (port 4570) endpoints.
- **Docker Network:** Containers communicate over a bridge network `app_net`.
- **Fault Injection:** Scripts use `tc` and `iptables` to simulate latency and partitions between datacenters.

### 3. Data Layer
- **PostgreSQL:**
    - Primary (AWS): Accepts Writes.
    - Standby (GCP): Read-only replica (async).
    - Failover: Scripts promote Standby to Primary.
- **Redis:**
    - Active-Active (simulated via conflict resolution in app) or Primary/Replica for queues.

## Data Flow
1. User Request -> API (AWS/GCP)
2. API -> Redis Queue (Local Region)
3. Consumer -> Reads Queue -> Writes to DB (Primary)
4. DB Primary -> Replicates to Standby
