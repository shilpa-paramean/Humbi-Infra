module "network" {
  count  = local.workspace.network.enabled ? 1 : 0
  source = "git::https://github.com/DNXLabs/terraform-aws-network.git?ref=1.8.3-compliance"
  
  name_suffix  = try(local.workspace.network.name_suffix, "")
  name_pattern = try(local.workspace.network.name_pattern, "default")

  max_az              = try(max(1, local.workspace.network.max_az), 3)
  newbits             = local.workspace.network.vpc_newbits
  vpc_cidr            = local.workspace.network.vpc_cidr
  name                = local.workspace.network.name
  nat                 = try(local.workspace.network.nat, true)
  multi_nat           = local.workspace.network.multi_nat
  transit_subnet      = false
  vpc_flow_logs       = try(local.workspace.network.vpc_flow_logs, true)

  kubernetes_clusters        = try(local.workspace.network.kubernetes_clusters, [])
  kubernetes_clusters_secure = try(local.workspace.network.kubernetes_clusters_secure, [])
  kubernetes_clusters_type   = try(local.workspace.network.kubernetes_clusters_type, "shared")
  

  public_nacl_inbound_tcp_ports  = try(local.workspace.network.public_nacl_inbound_tcp_ports, ["80", "443", "22", "1194"])
  public_nacl_outbound_tcp_ports = try(local.workspace.network.public_nacl_outbound_tcp_ports, ["0"])

  public_nacl_inbound_udp_ports  = try(local.workspace.network.public_nacl_inbound_udp_ports, [])
  public_nacl_outbound_udp_ports = try(local.workspace.network.public_nacl_outbound_udp_ports, ["0"])

  # private_nacl_inbound_tcp_ports = try(local.workspace.network.private_nacl_inbound_tcp_ports, [0])
  # private_nacl_inbound_udp_ports = try(local.workspace.network.private_nacl_inbound_udp_ports, [0])

  # secure_nacl_inbound_tcp_ports = try(local.workspace.network.secure_nacl_inbound_tcp_ports, [0])
  # secure_nacl_inbound_udp_ports = try(local.workspace.network.secure_nacl_inbound_udp_ports, [0])

  public_nacl_icmp              = true
  vpc_endpoints                 = local.workspace.network.vpc_endpoints
  vpc_endpoint_dynamodb_gateway = try(local.workspace.network.vpc_endpoint_dynamodb_gateway, false)
  vpc_endpoint_s3_gateway       = try(local.workspace.network.vpc_endpoint_s3_gateway, true)

  tags = {
    "TerraformWorkspace" = terraform.workspace
  }
    
}

# output "network" {
#   value = try(module.network[0], {})
# }
