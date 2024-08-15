# ----
# MAIN
# ----

resource "aws_transfer_server" "server" {
  identity_provider_type = "SERVICE_MANAGED"
  
  tags = {
    Name                          = local.sftp_server_name
    #"aws:transfer:customHostname" = local.sftp_custom_hostname
  }
}

#resource "aws_transfer_tag" "with_custom_domain_route53_zone_id" {
#  resource_arn = aws_transfer_server.server.arn
#  key          = "aws:transfer:route53HostedZoneId"
#  value        = local.hosted_zone_id
#}

#resource "aws_transfer_tag" "with_custom_domain_name" {
#  resource_arn = aws_transfer_server.server.arn
#  key          = "aws:transfer:customHostname"
#  value        = local.sftp_custom_hostname
#}

# resource "aws_transfer_tag" "hostname" {
#   resource_arn = aws_transfer_server.example.arn
#   key          = "aws:transfer:customHostname"
#   value        = local.sftp_custom_hostname
# }
