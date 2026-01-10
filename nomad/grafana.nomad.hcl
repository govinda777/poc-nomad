job "grafana" {
  datacenters = ["aws"]
  type        = "service"

  group "dashboard" {
    count = 1

    network {
      port "grafana" {
        static = 3000
      }
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:latest"
        ports = ["grafana"]
      }

      env {
        GF_SECURITY_ADMIN_USER     = "admin"
        GF_SECURITY_ADMIN_PASSWORD = "admin"
      }

      resources {
        cpu    = 100
        memory = 128
      }

      service {
        name = "grafana"
        port = "grafana"
        check {
          type     = "http"
          path     = "/api/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
