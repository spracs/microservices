resource "google_compute_disk" "default" {
  name = "reddit-mongo-disk"
  zone = var.zone
  type = "pd-ssd"
  size = 25
}
