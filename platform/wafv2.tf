module "terraform_aws_wafv2_global" {
  source   = "git::https://github.com/DNXLabs/terraform-aws-waf.git?ref=1.0.0"
  for_each = { for rule in try(local.workspace.wafv2.global.acls, []) : rule.global_rule_name => rule }

  providers = {
    aws = aws.us-east-1
  }

  waf_cloudfront_enable = try(each.value.waf_cloudfront_enable, false)

  global_rule               = try(each.value.global_rule_name, [])
  wafv2_managed_rule_groups = try(each.value.wafv2_managed_rule_groups, [])
  wafv2_rate_limit_rule     = try(each.value.wafv2_rate_limit_rule, 0)
  scope                     = each.value.scope
}


module "terraform_aws_wafv2_regional" {
  source   = "git::https://github.com/DNXLabs/terraform-aws-waf.git?ref=1.0.0"
  for_each = { for rule in try(local.workspace.wafv2.regional.acls, []) : rule.regional_rule_name => rule }

  waf_regional_enable = try(each.value.waf_regional_enable, false) # WAFv2 to ALB, API Gateway or AppSync GraphQL API

  regional_rule             = try(each.value.regional_rule_name, [])
  wafv2_managed_rule_groups = try(each.value.wafv2_managed_rule_groups, [])
  wafv2_rate_limit_rule     = try(each.value.wafv2_rate_limit_rule, 0)
  scope                     = each.value.scope
}
