module "acm_certificate" {
  for_each = {
    for certificate in local.workspace.acm.certificates : certificate.name => certificate
    if try(certificate.global, false) == false
  }
  source = "git::https://github.com/DNXLabs/terraform-aws-acm-certificate?ref=0.2.2"

  domain_names   = each.value.domain_names
  hosted_zone_id = can(each.value.hosted_zone) ? aws_route53_zone.default[each.value.hosted_zone].zone_id : ""
}

module "acm_certificate_global" {
  for_each = {
    for certificate in local.workspace.acm.certificates : certificate.name => certificate
    if try(certificate.global, false) == true
  }
  providers = { aws = aws.us-east-1 }
  source    = "git::https://github.com/DNXLabs/terraform-aws-acm-certificate?ref=0.2.2"

  domain_names   = each.value.domain_names
  hosted_zone_id = can(each.value.hosted_zone) ? aws_route53_zone.default[each.value.hosted_zone].zone_id : ""
}

output "acm_certificate" {
  value = element(module.acm_certificate[*], 0)
}

output "acm_certificate_global" {
  value = element(module.acm_certificate_global[*], 0)
}