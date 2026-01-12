job "prometheus" {
  datacenters = ["aws", "gcp"]
  type = "service"

  group "monitoring" {
    count = 1
    task "prometheus" {
      driver = "docker"
      config {
        image = "prom/prometheus:latest"
        args = ["--config.file=/etc/prometheus/prometheus.yml"]
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml"
        ]
        ports = ["http"]
      }

      template {
        data = <<EOF
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'nomad'
    metrics_path: '/v1/metrics'
    params:
      format: ['prometheus']
    static_configs:
      - targets: ['localhost:4646']
EOF
        destination = "local/prometheus.yml"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
