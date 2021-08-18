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
