resource "aws_wafv2_web_acl" "firewall" {
  name = "firewall"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled = true
    }
  }

  rule {
    name = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled = true
    }
  }

  rule {
    name = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name = "firewall"
    sampled_requests_enabled   = false
  }
}
