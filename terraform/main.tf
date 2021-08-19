terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.42.0"
    }
  }

  backend "s3" {
    key = "state"
    dynamodb_table = "terraform"
  }
}

provider "aws" {
}

module "certificate" {
  source = "./certificate"
  domain_name = var.domain_name
  zone_id = module.route53.zone_id
}

module "route53" {
  source = "./route53"
  domain_name = var.domain_name
  main_cloudfront_domain_name = module.main_cloudfront.cloudfront_domain_name
  main_cloudfront_hosted_zone_id = module.main_cloudfront.hosted_zone_id
  preview_cloudfront_domain_name = module.preview_cloudfront.cloudfront_domain_name
  preview_cloudfront_hosted_zone_id = module.preview_cloudfront.hosted_zone_id
}

module "waf" {
  source = "./waf"
}

module "iam" {
  source = "./iam"
  preview_s3_arn = module.preview_s3.arn
  preview_cloudfront_arn = module.preview_cloudfront.arn
}

module "main_s3" {
  source = "./s3"
  bucket_name = "${var.domain_name}-site"
  cloudfront_origin_access_identity_iam_arn = module.main_cloudfront.origin_access_identity_iam_arn
}

module "main_cloudfront" {
  source = "./cloudfront"
  domain_name = var.domain_name
  web_acl_arn = module.waf.arn
  acm_certificate_arn = module.certificate.arn
  s3_bucket_regional_domain_name = module.main_s3.regional_domain_name
}

module "preview_s3" {
  source = "./s3"
  bucket_name = "${var.domain_name}-preview"
  cloudfront_origin_access_identity_iam_arn = module.preview_cloudfront.origin_access_identity_iam_arn
}

module "preview_cloudfront" {
  source = "./cloudfront"
  domain_name = "*.preview.${var.domain_name}"
  web_acl_arn = module.waf.arn
  acm_certificate_arn = module.certificate.arn
  s3_bucket_regional_domain_name = module.main_s3.regional_domain_name
}
