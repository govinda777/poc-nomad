# Nomad Multi-Cloud Active-Active POC

This POC demonstrates an active-active architecture using HashiCorp Nomad, traversing AWS and GCP (simulated locally via LocalStack), handling data replication, network partitions, and failover.

## Requirements

- Docker & Docker Compose
- Make
- Go 1.21+

## Quick Start

For detailed setup instructions, please refer to the [Setup Guide](docs/SETUP.md).

1.  **Configure Environment:**
    Copy `.env.example` to `.env` (or create one) and set the required passwords.

2.  **Start Environment:**
    ```bash
    make up
    ```

3.  **Run Tests:**
    ```bash
    make test-active-active
    ```

## Documentation

*   [**Setup Guide**](docs/SETUP.md): Detailed installation and running instructions.
*   [**API Reference**](docs/API.md): Documentation for the Application API.
*   [**Architecture**](docs/ARCHITECTURE.md): High-level system design.
*   [**Network Rules**](docs/NETWORK_RULES.md): Details on network simulation (VPN, firewall, latency).
*   [**Problems & Solutions**](docs/PROBLEMS.md): Common distributed system challenges handled in this POC.
*   [**Secrets Management**](docs/SECRETS.md): How to handle secrets and security.
*   [**Agents Guidelines**](docs/AGENTS.md): Development guidelines.

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
