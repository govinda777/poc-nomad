# Agents

## Guidelines

### Security (Critical)
**Read `docs/SECURITY.md` before making any changes.**

*   **Secrets:**
    *   **NEVER** commit secrets (passwords, keys, tokens).
    *   Check `app/config/config.go`, `nomad/*.hcl`, `terraform/**/*.tf`, and `docker-compose.yml` for hardcoded secrets.
    *   Use environment variables for all sensitive data.
*   **Files:** Do NOT create or commit `.env` or `.env.example`.
*   **Go Version:** Maintain Go 1.21 in `go.mod`.

### Testing
*   **Tests:** Always run `make test-active-active` before submitting.
*   **Pre-commit:** Verify no secrets are being added.

### Structure
*   **Structure:** Keep `app/` clean.
