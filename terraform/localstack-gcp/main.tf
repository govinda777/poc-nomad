terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "poc-project"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# In a real scenario, we would configure endpoints for LocalStack here if using a LocalStack-aware provider wrapper
# or simply rely on the fact that we are running this against LocalStack via CLI overrides or environment variables.
# For this POC, we define the resources as standard GCP resources.

resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "test-subnetwork"
  ip_cidr_range = "172.21.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "4646", "4647"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "nomad_server" {
  name         = "nomad-server-gcp"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name
  }
}
