module "vpn" {
  source                           = "git::https://github.com/DNXLabs/terraform-aws-client-vpn.git?ref=0.4.2"
  count                            = local.workspace.vpn.enabled ? 1 : 0
  name                             = try(local.workspace.vpn.name, "")
  cidr                             = try(local.workspace.vpn.cidr, "")
  subnet_ids                       = [module.network[0].private_subnet_ids[0]]
  vpc_id                           = module.network[0].vpc_id
  organization_name                = local.workspace.org_name
  tags                             = {}
  logs_retention                   = try(local.workspace.vpn.logs_retention, 365)
  authentication_type              = "federated-authentication"
  authentication_saml_provider_arn = try(local.workspace.vpn.saml_provider_arn, "")
  split_tunnel                     = try(local.workspace.vpn.split_tunnel, true)
  allowed_cidr_ranges              = length(try(local.workspace.vpn.allowed_access_groups, [])) > 0 ? [module.network[0].cidr_block] : []
  allowed_access_groups            = try(local.workspace.vpn.allowed_access_groups, [])
}

output "vpn_sg_id" {
  value = try(module.vpn[0].security_group_id, "")
}