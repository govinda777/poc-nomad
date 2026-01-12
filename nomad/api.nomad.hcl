job "api" {
  datacenters = ["aws"]
  type        = "service"

  group "api-group" {
    count = 3

    network {
      port "http" {
        to = 8080
      }
    }

    task "api-task" {
      driver = "docker"

      config {
        image = "poc-nomad-api:latest"
        ports = ["http"]
        args = ["-datacenter=aws"]
      }

      env {
        DB_HOST = "172.20.1.100"
        REDIS_HOST = "172.20.1.110"
        DATACENTER = "aws"
      }
    }
  }
}
