job "consumer" {
  datacenters = ["aws", "gcp"]
  type        = "service"

  group "worker" {
    count = 2

    task "consumer" {
      driver = "docker"

      config {
        image = "poc-app:latest"
        # The main entrypoint starts the API, but also a background consumer.
        # We can reuse the image.
      }

      env {
        DATACENTER = "${node.datacenter}"
        DB_HOST    = "${node.datacenter == \"aws\" ? \"172.20.1.100\" : \"172.21.1.100\"}"
        REDIS_HOST = "${node.datacenter == \"aws\" ? \"172.20.1.110\" : \"172.21.1.110\"}"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
