variable "project" {
  description = "my project name"
  default     = "your_alias_project_name"
  type        = string
}

variable "bucket_name" {
  description = "my bucket name"
  default     = "your_bucket_name"
  type        = string
}

variable "bucket_region" {
  description = "my bucket region"
  default     = "US"
  type        = string
}

variable "domain" {
  description = "domain for ssl certs"
  default     = "your_domain_goes_here"
  type        = string
}
