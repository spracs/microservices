resource "google_compute_http_health_check" "kub_health" {
  name         = "kubernetes"
  request_path = "/healthz"
  host         = "kubernetes.default.svc.cluster.local"
}

resource "google_compute_firewall" "firewall_health_check" {
  name    = "kubernetes-the-hard-way-allow-health-check"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
  }
  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
}

resource "google_compute_forwarding_rule" "kube_forw_rule" {
  name       = "kubernetes-forwarding-rule"
  ip_address = google_compute_address.public_address.address
  target     = google_compute_target_pool.kube_target.self_link
  port_range = "6443"
}

resource "google_compute_target_pool" "kube_target" {
  name      = "kubernetes-target-pool"
  instances = google_compute_instance.kub-controller.*.self_link

  health_checks = [
    google_compute_http_health_check.kub_health.id,
  ]
}
