# Setup Guide

This guide provides detailed instructions for setting up and running the Nomad Multi-Cloud Active-Active POC locally.

## Prerequisites

Ensure you have the following installed on your machine:

-   **Docker**: v20.10+ (with Docker Compose v1.29+ or v2.x)
-   **Go**: v1.21+ (for local development, though the POC runs in containers)
-   **Make**: Standard build tool (pre-installed on most Linux/macOS systems).
-   **curl**: For testing endpoints.
-   **jq**: (Optional) For pretty-printing JSON responses in tests.

## Configuration

1.  **Clone the Repository:**
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2.  **Environment Variables:**
    Create a `.env` file in the root directory. This file is ignored by Git and must not be committed.

    ```bash
    cp .env.example .env # If .env.example exists, otherwise create .env
    ```

    **Required Variables:**
    ```ini
    # Postgres Configuration
    POSTGRES_USER=poc
    POSTGRES_PASSWORD=secure_password_here
    POSTGRES_DB=pocdb

    # Grafana Configuration
    GF_SECURITY_ADMIN_USER=admin
    GF_SECURITY_ADMIN_PASSWORD=secure_grafana_password
    ```

    > **Security Note:** Never use production passwords for this POC. The defaults are for local simulation only.

## Running the Environment

The project uses `docker-compose` to simulate the multi-cloud environment (AWS/LocalStack, GCP, Nomad, Postgres, Redis).

1.  **Start the Infrastructure:**
    ```bash
    make up
    ```
    This command builds the necessary images and starts the containers in the background. It waits for 10 seconds to ensure services are initializing.

2.  **Verify Status:**
    Check if all containers are running:
    ```bash
    docker-compose ps
    ```
    You should see containers for:
    -   `localstack` (AWS simulation)
    -   `nomad-server-aws`, `nomad-server-gcp`
    -   `postgres-aws-primary`, `postgres-gcp-standby`
    -   `redis-aws`, `redis-gcp`
    -   `api-aws`, `api-gcp` (The application instances)

3.  **Access Services:**
    -   **AWS API Instance**: http://localhost:8081
    -   **GCP API Instance**: http://localhost:8082
    -   **Grafana**: http://localhost:3000
    -   **Prometheus**: http://localhost:9090

## Stopping the Environment

To stop and remove all containers and volumes:

```bash
make down
```

## Running Tests

The project includes automated tests for various scenarios:

1.  **Active-Active Sync Test:**
    Verifies that writes to one region eventually appear in the other.
    ```bash
    make test-active-active
    ```

2.  **Network Partition Test:**
    Simulates a VPN failure between regions and verifies behavior.
    ```bash
    make test-network-partition
    ```

3.  **Failover Test:**
    Simulates a primary region failure.
    ```bash
    make test-failover
    ```

## Troubleshooting

-   **Port Conflicts:** Ensure ports 8081, 8082, 3000, 9090, and 5432 are free.
-   **Docker Memory:** LocalStack and Nomad can be resource-intensive. Ensure Docker has at least 4GB of RAM allocated.
