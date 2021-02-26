provider "google" {
  version = "~> 2.5.0"
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "kubernetes-the-hard-way"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "kubernetes"
  ip_cidr_range = "10.240.0.0/24"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "firewall_int" {
  name        = "kubernetes-the-hard-way-allow-internal"
  network     = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]
}

resource "google_compute_firewall" "firewall_ext" {
  name        = "kubernetes-the-hard-way-allow-external"
  network     = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "public_address" {
  name      = "kubernetes-the-hard-way"
  region    = var.region
}

resource "google_compute_instance" "kub-controller" {
  count        = var.counter
  name         = "controller-${count.index}"
  machine_type = "e2-standard-2"
  can_ip_forward = true
  tags         = ["kubernetes-the-hard-way", "controller"]
  metadata = {
    ssh-keys = "${var.username}:${file(var.public_key_path)}"
  }
  labels = {
    "ansible" = "controller",
    "controller" = "${count.index}"
  }

  boot_disk {
    initialize_params {
      size = 200
      image = var.disk_image
    }
  }

  network_interface {
    subnetwork     = google_compute_subnetwork.vpc_subnet.id
    network_ip = "10.240.0.1${count.index}"
    access_config { 
    }
  }
  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
}

resource "google_compute_instance" "kub-worker" {
  count        = var.counter
  name         = "worker-${count.index}"
  machine_type = "e2-standard-2"
  can_ip_forward = true
  tags         = ["kubernetes-the-hard-way", "worker"]
  metadata = {
    pod-cidr = "10.200.${count.index}.0/24"
    ssh-keys = "${var.username}:${file(var.public_key_path)}"
  }
  labels = {
    "ansible" = "worker"
  }

  boot_disk {
    initialize_params {
      size = 200
      image = var.disk_image
    }
  }

  network_interface {
    subnetwork     = google_compute_subnetwork.vpc_subnet.id
    network_ip = "10.240.0.2${count.index}"
    access_config { 
    }
  }
  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
}

resource "google_compute_route" "kub_routes" {
  count        = var.counter
  name        = "kubernetes-route-10-200-${count.index}-0-24"
  dest_range  = "10.200.${count.index}.0/24"
  network     = google_compute_network.vpc_network.name
  next_hop_ip = "10.240.0.2${count.index}"
  depends_on = [
    google_compute_instance.kub-worker,
  ]
}
