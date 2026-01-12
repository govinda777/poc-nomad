# Security Guidelines

## Overview
This document outlines the security policies and best practices for the Nomad Multi-Cloud POC. These rules were established following security incidents (see PR #2) and must be strictly adhered to.

## 1. Secrets Management
**Rule: NEVER Hardcode Secrets.**

### 1.1 Application Code (Go)
*   **Do not** store passwords, API keys, or tokens in variables or constants within the source code.
*   **Do:** Use environment variables.
*   **Example (`app/config/config.go`):**
    ```go
    // BAD
    DBPassword: "mysecretpassword"

    // GOOD
    DBPassword: getEnv("POSTGRES_PASSWORD", "")
    ```

### 1.2 Nomad Jobs (`.nomad.hcl`)
*   **Do not** write passwords directly in `env` blocks.
*   **Do:** Use variable interpolation.
*   **Example (`nomad/grafana.nomad.hcl`):**
    ```hcl
    // BAD
    env {
        GF_SECURITY_ADMIN_PASSWORD = "admin"
    }

    // GOOD
    env {
        GF_SECURITY_ADMIN_PASSWORD = "${GF_SECURITY_ADMIN_PASSWORD}"
    }
    ```

### 1.3 Terraform (`.tf`)
*   **Do not** provide default values for variables that represent secrets.
*   **Do:** Declare the variable and provide the value at runtime (via `TF_VAR_` env vars or `.tfvars` file which is gitignored).
*   **Example:**
    ```hcl
    // BAD
    variable "db_password" {
      default = "secret123"
    }

    // GOOD
    variable "db_password" {
      type        = string
      sensitive   = true
    }
    ```

### 1.4 Docker Compose (`docker-compose.yml`)
*   **Do not** hardcode passwords in `environment` sections.
*   **Do:** Use variable substitution from the host environment.
*   **Example:**
    ```yaml
    # BAD
    environment:
      - POSTGRES_PASSWORD=secret

    # GOOD
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    ```

## 2. Environment Variables
*   **Prohibited Files:** Never commit `.env` or `.env.example` files. These files often get copied and accidentally committed with real secrets.
*   **Documentation:** Document required environment variables in `README.md` using a template format.
*   **Gitignore:** Ensure `.env` and `*.env` are in `.gitignore`.

## 3. Dependencies
*   **Go Version:** Ensure `go.mod` matches the version used in `Dockerfile` (currently Go 1.21).
*   **Vulnerability Scanning:** Use tools like `gitguardian` or `trivy` to scan for secrets and vulnerabilities before committing.

## 4. Incident Response
If a secret is committed:
1.  **Revoke** the secret immediately.
2.  **Rotate** the credential in the source system.
3.  **Rewrite History** (if possible and safe) to remove the secret from git history, or squash the commit.
4.  **Document** the incident and prevent recurrence.
