provider "google" {
  version = "~> 2.5.0"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "gitlab" {
  name         = "gitlab-ci"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["gitlab-ci"]
  labels = {
    "ansible" = "gitlab"
  }

  boot_disk {
    initialize_params {
      image = var.disk_image
      size  = var.disk_size
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.gitlab_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.username}:${file(var.public_key_path)}"
  }
}

resource "google_compute_address" "gitlab_ip" {
  name = "gitlab-ip"
}

resource "google_compute_firewall" "firewall_http" {
  name    = "allow-http-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gitlab-ci"]
}
