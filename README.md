# POC: Nomad Multi-Cloud Active-Active (Local Simulation)

This Proof of Concept (POC) demonstrates a robust Multi-Cloud Active-Active architecture using **HashiCorp Nomad** as the orchestrator. It is designed to run **100% locally** using **LocalStack** to simulate AWS and GCP environments, along with Docker-based network simulation tools (`tc`, `iptables`) to replicate real-world challenges like network partitions, latency, and packet loss.

## Architecture Overview

The system simulates two datacenters:
- **DC1 (AWS Simulation):** Primary Database, Nomad Server/Client, API, Consumer.
- **DC2 (GCP Simulation):** Standby Database (Streaming Replication), Nomad Server/Client, API, Consumer.

They are connected via a simulated "VPN" (Docker Network routing) which can be manipulated to demonstrate failure scenarios.

## Prerequisites

- Docker & Docker Compose
- `make`
- `curl`

## Quick Start

1.  **Start the Infrastructure:**
    ```bash
    make up
    ```
    This will:
    - Start LocalStack instances (AWS & GCP).
    - Start PostgreSQL instances (Primary & Standby).
    - Start Redis instances.
    - Start Nomad Clusters.
    - Deploy the Application Jobs.
    - Establish the initial network connectivity ("VPN Up").

2.  **Verify Status:**
    - Grafana: [http://localhost:3000](http://localhost:3000) (admin/admin)
    - AWS API: [http://172.20.1.30:8080/health](http://172.20.1.30:8080/health)
    - GCP API: [http://172.21.1.30:8080/health](http://172.21.1.30:8080/health)

3.  **Run Tests:**
    ```bash
    make test-active-active
    make test-network-partition
    make test-failover
    ```

## Key Features

- **Replication Strategy:** PostgreSQL Streaming Replication with WAL.
- **Conflict Resolution:** Last-Write-Wins (LWW) handled by the application.
- **Orchestration:** Nomad federation across simulated clouds.
- **Observability:** Prometheus metrics for replication lag, queue depth, and API latency.

## Directory Structure

- `app/`: Go source code for the microservices.
- `nomad/`: Job specifications (`.hcl`).
- `terraform/`: Infrastructure as Code for LocalStack.
- `scripts/`: Network simulation and helper scripts.
- `tests/`: Automated bash test suites.
