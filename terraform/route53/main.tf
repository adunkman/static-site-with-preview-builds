resource "aws_route53_zone" "zone" {
  name = var.domain_name
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.zone.zone_id
  name = aws_route53_zone.zone.name
  type = "A"

  alias {
    name = var.main_cloudfront_domain_name
    zone_id = var.main_cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "preview" {
  zone_id = aws_route53_zone.zone.zone_id
  name = "preview.${var.domain_name}"
  type = "A"

  alias {
    name = var.preview_cloudfront_domain_name
    zone_id = var.preview_cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.zone.zone_id
  name = "*.${var.domain_name}"
  type = "CNAME"
  ttl = 30
  records = ["preview.${var.domain_name}"]
}
