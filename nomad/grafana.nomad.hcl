job "grafana" {
  datacenters = ["aws"]
  type = "service"

  group "dashboard" {
    count = 1
    task "grafana" {
      driver = "docker"
      config {
        image = "grafana/grafana:latest"
        ports = ["http"]
      }

      env {
        GF_SECURITY_ADMIN_USER = "admin"
        GF_SECURITY_ADMIN_PASSWORD = "admin"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
