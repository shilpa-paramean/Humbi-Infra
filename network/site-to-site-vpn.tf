locals {
  route_table_ids = concat(
    try(local.workspace.site_to_site_vpn.route_secure_subnets, false) ? [module.network[0].secure_route_table_id] : [],
    try(local.workspace.site_to_site_vpn.route_private_subnets, false) ? module.network[0].private_route_table_id : [],
    try(local.workspace.site_to_site_vpn.route_public_subnets, false) ? [module.network[0].public_route_table_id] : [],
  )
}

module "site_to_site_vpn" {
  source                                    = "cloudposse/vpn-connection/aws"
  version                                   = "0.7.1"
  count                                     = try(local.workspace.site_to_site_vpn.enabled, false) ? 1 : 0
  name                                      = try(local.workspace.site_to_site_vpn.name, null)
  vpc_id                                    = module.network[0].vpc_id
  customer_gateway_bgp_asn                  = try(local.workspace.site_to_site_vpn.bgp_asn, null)
  customer_gateway_ip_address               = try(local.workspace.site_to_site_vpn.ip_address, null)
  vpn_connection_static_routes_only         = try(local.workspace.site_to_site_vpn.static_only, false) ? "true" : "false"
  vpn_connection_static_routes_destinations = try(local.workspace.site_to_site_vpn.static_route_destinations, [])
  route_table_ids                           = local.route_table_ids
  vpn_connection_local_ipv4_network_cidr    = try(local.workspace.site_to_site_vpn.local_cidr, null)
  vpn_connection_remote_ipv4_network_cidr   = try(local.workspace.site_to_site_vpn.remote_cidr, null)
}
