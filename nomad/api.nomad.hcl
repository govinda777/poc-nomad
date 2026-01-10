job "api" {
  datacenters = ["aws", "gcp"]
  type        = "service"

  group "api-server" {
    count = 3

    network {
      port "http" {
        to = 8080
      }
    }

    task "api" {
      driver = "docker"

      config {
        image = "poc-app:latest"
        ports = ["http"]
        # In a real setup, we would use Consul to discover DB/Redis.
        # Here we hardcode or use env vars based on the node's location.
        # Nomad interpolation can help if we had meta.dc properties.
      }

      env {
        DATACENTER = "${node.datacenter}"
        # Simplified: In simulation, we need to know which DB IP to use based on DC.
        # We can use template to render config based on DC.
        DB_HOST    = "${node.datacenter == \"aws\" ? \"172.20.1.100\" : \"172.21.1.100\"}"
        REDIS_HOST = "${node.datacenter == \"aws\" ? \"172.20.1.110\" : \"172.21.1.110\"}"
      }

      resources {
        cpu    = 100
        memory = 128
      }

      service {
        name = "api"
        port = "http"
        tags = ["urlprefix-/orders"]
        check {
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
