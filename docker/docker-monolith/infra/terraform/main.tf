provider "google" {
  version = "~> 2.5.0"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "docker" {
  count        = var.counter
  name         = "docker-${count.index}"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["docker-machine"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config { 
     
    }
  }
}
