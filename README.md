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

## Documentation

*   [Architecture](docs/ARCHITECTURE.md): High-level system design.
*   [Secrets Management](docs/SECRETS.md): How to handle secrets and security.
*   [Agents Guidelines](docs/AGENTS.md): Development guidelines.

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

**Note:** For Terraform, see [Secrets Management](docs/SECRETS.md).

## Troubleshooting

If Docker Hub limits occur, wait or login.
