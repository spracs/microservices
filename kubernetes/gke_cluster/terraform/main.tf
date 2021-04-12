provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  enable_legacy_abac       = true
  addons_config {
    network_policy_config { disabled = false }
  }
  network_policy {
    enabled  = true
    provider = "CALICO"
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    #    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
