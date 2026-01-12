job "consumer" {
  datacenters = ["aws"]
  type        = "service"

  group "consumer-group" {
    count = 2

    task "consumer-task" {
      driver = "docker"

      config {
        image = "poc-nomad-api:latest"
        args = ["consumer"]
      }

      env {
        DB_HOST = "172.20.1.100"
        REDIS_HOST = "172.20.1.110"
        DATACENTER = "aws"
      }
    }
  }
}
