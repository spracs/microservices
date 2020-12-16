variable "project" {
  description = "Project ID"
}

variable "region" {
  description = "Region"
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone"
  default     = "europe-west1-b"
}

variable "machine_type" {
  description = "Machine type"
  default     = "n1-standard-1"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "privat_key_path" {
  description = "Path to the privat key used for ssh access"
}

variable "disk_image" {
  description = "Disk image"
}

variable "disk_size" {
  description = "Disk size"
}

variable "username" {
  description = "User name"
  default     = "appuser"
}
