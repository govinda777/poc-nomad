# Nomad Multi-Cloud Active-Active POC

This POC demonstrates an active-active architecture using HashiCorp Nomad, traversing AWS and GCP (simulated locally via LocalStack), handling data replication, network partitions, and failover.

## Requirements

- Docker & Docker Compose
- Make
- Go 1.21+

## Quick Start

1.  **Start Environment:**
    ```bash
    make up
    ```

2.  **Run Tests:**
    ```bash
    make test-active-active
    make test-network-partition
    make test-failover
    ```

3.  **Observability:**
    -   Grafana: http://localhost:3000 (admin/admin)
    -   Prometheus: http://localhost:9090

## Architecture

See `docs/ARCHITECTURE.md` (conceptual).

-   **AWS Region:** Simulated by LocalStack (Port 4566), running Nomad DC1, Postgres Primary, Redis Primary.
-   **GCP Region:** Simulated by LocalStack (Port 4570), running Nomad DC2, Postgres Standby, Redis Replica.
-   **App:** Go API + Consumer, deployed as Docker containers (simulating Nomad jobs).

## Environment Variables

Create a `.env` file in the root directory. **DO NOT COMMIT `.env`**.

Required variables:
- `POSTGRES_USER` (default: poc)
- `POSTGRES_PASSWORD` (REQUIRED)
- `POSTGRES_DB` (default: pocdb)
- `GF_SECURITY_ADMIN_USER` (default: admin)
- `GF_SECURITY_ADMIN_PASSWORD` (REQUIRED)

Example content for `.env`:
```
POSTGRES_USER=poc
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=pocdb
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=your_secure_grafana_password
```

## Troubleshooting

If Docker Hub limits occur, wait or login.
