variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default = "europe-west1"
}

variable zone {
  description = "Zone"
  default = "europe-west1-b"
}

variable "counter" {
  description = "Count of instances"
  default = "1"
}

variable disk_image {
  description = "Disk image"
}
