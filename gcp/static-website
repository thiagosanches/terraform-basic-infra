provider "google" {
  project = "your_project_goes_here"
}

# Create new storage bucket in the US region
# with coldline storage
resource "google_storage_bucket" "static_bucket" {
  name          = "${var.project}-${var.bucket_name}"
  location      = var.bucket_region
  storage_class = "COLDLINE"
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_compute_backend_bucket" "static_bucket_backend" {
  name        = "${var.project}-static-bucket-backend"
  description = "Contains static resources for the application"
  bucket_name = google_storage_bucket.static_bucket.name
  enable_cdn  = true
}

resource "google_storage_bucket_iam_binding" "viewers" {
  bucket   = google_storage_bucket.static_bucket.name
  role     = "roles/storage.objectViewer"
  members = ["allUsers"]
}

resource "google_compute_url_map" "urlmap" {
  name            = "${var.project}-lb"
  default_service = google_compute_backend_bucket.static_bucket_backend.id

  host_rule {
    hosts        = ["${var.domain}"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.static_bucket_backend.id
  }
}

resource "google_compute_target_https_proxy" "default-ssl" {
  name             = "${var.project}-target-proxy-ssl"
  description      = "Target proxy SSL"
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
  url_map          = google_compute_url_map.urlmap.self_link
}

resource "google_compute_global_forwarding_rule" "default-ssl" {
  name       = "${var.project}-frontend-https"
  target     = google_compute_target_https_proxy.default-ssl.self_link
  port_range = "443"
  ip_address = google_compute_global_address.lb_ip_address.address
}

resource "google_compute_global_address" "lb_ip_address" {
  name = "${var.project}-external-ip-address"
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "${var.project}-cert"

  managed {
    domains = ["${var.domain}"]
  }
}

output "lb_ip_address" { 
    value = google_compute_global_address.lb_ip_address.address
}
