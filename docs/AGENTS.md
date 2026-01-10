# Agents Guide

This repository contains a complex local simulation of a multi-cloud environment.

## Critical Constraints

1.  **LocalStack Usage:** Do not try to authenticate with real AWS or GCP credentials. All Terraform and AWS CLI commands must use the LocalStack endpoints (default `http://localhost:4566` for AWS, `http://localhost:4570` for "GCP").
2.  **Network Simulation:** The Docker networks `aws-network` (172.20.x.x) and `gcp-network` (172.21.x.x) are isolated by default in standard Docker, but we bridge them via `iptables` scripts. Do not manually modify Docker network settings without checking `scripts/network_sim/`.
3.  **Container Capabilities:** Containers that need to manipulate network traffic (the "routers" or the nodes themselves if we run simulation there) require `NET_ADMIN`.
4.  **Database Replication:** The PostgreSQL setup relies on specific `pg_hba.conf` and `postgresql.conf` settings injected via the command line or config files. Ensure `wal_level=replica` is maintained.

## Coding Standards

- **Go:** Use standard formatting (`gofmt`).
- **Scripts:** Ensure all bash scripts have `#!/bin/bash` and executable permissions.
- **Terraform:** Use `terraform fmt`.

## Testing

Always verify changes by running the relevant `make test-*` command. The environment state is mutable; use `make down && make up` to reset if a test leaves the system in a bad state.
