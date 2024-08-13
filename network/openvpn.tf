module "openvpn" {
  count = try(local.workspace.openvpn.enabled, false) ? 1 : 0

  source             = "git::https://github.com/DNXLabs/terraform-aws-openvpn.git?ref=1.4.3"
  name               = try(local.workspace.openvpn.name, "")
  instance_type_1    = try(local.workspace.openvpn.instance_types[0], "")
  instance_type_2    = try(local.workspace.openvpn.instance_types[1], "")
  instance_type_3    = try(local.workspace.openvpn.instance_types[2], "")
  private_subnet_ids = module.network[0].private_subnet_ids
  public_subnet_ids  = module.network[0].public_subnet_ids
  secure_subnet_ids  = module.network[0].secure_subnet_ids
  vpc_id             = module.network[0].vpc_id
  route_push         = try(local.workspace.openvpn.route_push, "")
  mfa                = true
  protocol           = "tcp"
  domain_name        = try(local.workspace.openvpn.domain_name, "")
  hosted_zone_id     = try(aws_route53_zone.default[local.workspace.openvpn.hosted_zone].zone_id, "")
}

# output "ecs_nodes_secgrp_id" {
#   value = module.openvpn[0].ecs_nodes_secgrp_id
# }