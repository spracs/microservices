output "gitlab-ci_external_ip" {
  value = google_compute_instance.gitlab.network_interface.0.access_config.0.nat_ip
}
output "docker-dev_external_ip" {
  value = google_compute_instance.docker.network_interface.0.access_config.0.nat_ip
}
