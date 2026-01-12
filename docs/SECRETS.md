# Secret Management

This project handles secrets using environment variables and ensures no sensitive data is committed to the repository.

## Principles

1.  **Environment Variables**: All secrets (database passwords, API keys, etc.) are injected via environment variables.
2.  **No `.env` Commits**: The `.env` file is strictly ignored in `.gitignore`. A `.env.example` (or instructions in README) is provided for template purposes, but the actual file must never be committed.
3.  **LocalStack Credentials**:
    *   The Terraform configuration for LocalStack uses `test`/`test` as dummy access and secret keys.
    *   These are **not** real AWS credentials.
    *   They are defined as defaults in `variables.tf` to allow overriding if necessary, but are safe to be public as they only work against the local simulation.
    *   **Note**: Automated security scanners (like GitGuardian) might flag these as "hardcoded secrets". This is a false positive in the context of LocalStack, but we have moved them to variables to minimize noise.

## Required Secrets

The following environment variables must be set (typically in `.env`):

*   `POSTGRES_PASSWORD`: Password for the PostgreSQL database.
*   `GF_SECURITY_ADMIN_PASSWORD`: Password for Grafana admin user.

## Terraform Variables

When running Terraform, you must provide sensitive variables via `terraform.tfvars` (which is ignored) or environment variables (e.g., `TF_VAR_db_password`).

Example `terraform.tfvars`:

```hcl
db_password = "your_secure_password"
```
