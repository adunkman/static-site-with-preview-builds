output "arn" {
  value = aws_cloudfront_distribution.distribution.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "origin_access_identity_iam_arn" {
  value = aws_cloudfront_origin_access_identity.identity.iam_arn
}
