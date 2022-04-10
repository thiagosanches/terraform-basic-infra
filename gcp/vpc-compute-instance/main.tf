provider "google"{
    project = "your_project_goes_here"
}

resource "google_compute_network" "vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

resource "google_compute_firewall" "allow-internal" {
  name    = "my-vpc-fw-allow-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    "${var.uc1_private_subnet}",
    "${var.ue1_private_subnet}",
    "${var.uc1_public_subnet}",
    "${var.ue1_public_subnet}"
  ]
}

resource "google_compute_firewall" "allow-vnc" {
  name    = "my-fw-allow-http"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["5901"]
  }
  source_tags = [ "vnc" ]
  target_tags = [ "vnc" ]
  source_ranges = [ "0.0.0.0/0" ]
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "my-pub-net"
  ip_cidr_range = var.uc1_public_subnet
  network       = google_compute_network.vpc.id
  region        = "southamerica-east1"
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "my-pri-net"
  ip_cidr_range = var.uc1_private_subnet
  network       = google_compute_network.vpc.id
  region        = "southamerica-east1"
}

resource "google_compute_instance" "default" {
  name         = "remove-me-please"
  machine_type = "e2-micro"
  zone         = "southamerica-east1-b"
  tags         = ["ssh", "vnc"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20211212"
      size  = 20
    }
  }

  metadata_startup_script  = <<SCRIPT
    DEBIAN_FRONTEND=noninteractive
    sudo apt update
    sudo apt install -y openbox tightvncserver firefox xterm
    mkdir ~/.vnc 
    echo "your_password_goes_here" | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
    USER=root HOME=/root vncserver
  SCRIPT

  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.name
    access_config {
      //EPHEMERAL IP
    }
  }
}

output "instance_ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
