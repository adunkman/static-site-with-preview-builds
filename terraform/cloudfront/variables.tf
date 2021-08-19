variable "web_acl_arn" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "s3_bucket_regional_domain_name" {
  type = string
}

variable "viewer_request_arn" {
  type = string
  default = null
}
