# API Documentation

The application exposes a REST API for managing orders. The API is deployed in both simulated regions (AWS and GCP).

## Base URLs

-   **AWS Region**: `http://localhost:8081`
-   **GCP Region**: `http://localhost:8082`

## Endpoints

### 1. Health Check

Checks the status of the service and identifies the datacenter it is running in.

-   **URL**: `/health`
-   **Method**: `GET`
-   **Response**:
    ```json
    {
      "status": "ok",
      "dc": "aws" // or "gcp"
    }
    ```

### 2. Create Order

Creates a new order. The order is written to the local database and published to the queue.

-   **URL**: `/orders`
-   **Method**: `POST`
-   **Body**:
    ```json
    {
      "item": "Laptop",
      "qty": 1
    }
    ```
-   **Response (201 Created)**:
    ```json
    {
      "id": 101,
      "item": "Laptop",
      "qty": 1,
      "status": "pending",
      "datacenter": "aws",
      "created_at": "2023-10-27T10:00:00Z",
      "updated_at": "0001-01-01T00:00:00Z"
    }
    ```

### 3. Get Order by ID

Retrieves a specific order by its ID.

-   **URL**: `/orders/:id`
-   **Method**: `GET`
-   **Response (200 OK)**:
    ```json
    {
      "id": 101,
      "item": "Laptop",
      "qty": 1,
      "status": "pending",
      "datacenter": "aws",
      "created_at": "2023-10-27T10:00:00Z",
      "updated_at": "2023-10-27T10:00:00Z"
    }
    ```
-   **Response (404 Not Found)**:
    ```json
    {
      "error": "Order not found"
    }
    ```

### 4. List Orders

Retrieves a list of all orders.

-   **URL**: `/orders`
-   **Method**: `GET`
-   **Response (200 OK)**:
    ```json
    [
      {
        "id": 101,
        "item": "Laptop",
        "qty": 1,
        "status": "pending",
        "datacenter": "aws",
        "created_at": "2023-10-27T10:00:00Z"
      },
      {
        "id": 102,
        "item": "Mouse",
        "qty": 2,
        "status": "pending",
        "datacenter": "gcp",
        "created_at": "2023-10-27T10:05:00Z"
      }
    ]
    ```
