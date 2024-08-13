module "aws_dms_endpoint" {
  source   = "git::https://github.com/DNXLabs/terraform-aws-dms-endpoint.git?ref=0.0.2"
  for_each = { for endpoint in try(local.workspace.dms.endpoint, []) : endpoint.endpoint_id => endpoint }

  endpoint_id     = each.value.endpoint_id
  endpoint_type   = each.value.endpoint_type
  engine_name     = each.value.engine_name
  kms_key_arn     = try(each.value.kms_key_arn, "")
  certificate_arn = try(each.value.certificate_arn, "")

  server_name                 = each.value.server_name
  database_name               = each.value.database_name
  username                    = each.value.username
  password                    = try(data.aws_ssm_parameter.rds[each.value.endpoint_id].value, "")
  port                        = each.value.port
  extra_connection_attributes = ""
  ssl_mode                    = try(each.value.ssl_mode, "none")
  environment_name            = local.workspace.account_name
}