job "prometheus" {
  datacenters = ["aws"]
  type        = "service"

  group "monitoring" {
    count = 1

    network {
      port "prometheus" {
        static = 9090
      }
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:latest"
        ports = ["prometheus"]
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml"
        ]
      }

      template {
        data = <<EOF
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: 'nomad'
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
    static_configs:
      - targets: ['172.20.1.20:4646', '172.21.1.20:4646']

  - job_name: 'app-aws'
    static_configs:
      - targets: ['172.20.1.30:8080']

  - job_name: 'app-gcp'
    static_configs:
      - targets: ['172.21.1.30:8080']
EOF
        destination = "local/prometheus.yml"
      }

      resources {
        cpu    = 100
        memory = 128
      }

      service {
        name = "prometheus"
        port = "prometheus"
        check {
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
