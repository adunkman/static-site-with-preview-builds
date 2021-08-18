resource "random_id" "s3_origin_id" {
  byte_length = 8
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled = true
  is_ipv6_enabled = true
  web_acl_id = var.web_acl_arn

  aliases = [ var.domain_name ]
  default_root_object = "index.html"

  custom_error_response {
    error_caching_min_ttl = 3600
    error_code = 404
    response_code = 404
    response_page_path = "/404.html"
  }

  origin {
    domain_name = var.s3_bucket_regional_domain_name
    origin_id = random_id.s3_origin_id.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = random_id.s3_origin_id.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress = true
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "identity" {
}
