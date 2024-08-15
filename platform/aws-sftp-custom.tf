module "aws_sftp" {
  count      = local.workspace.custom.aws_sftp.enabled != true ? 0 : 1
  source     = "./modules/aws_sftp"
  sftp_server_name       = local.workspace.custom.aws_sftp.name
  sftp_custom_hostname   = local.workspace.custom.aws_sftp.custom_hostname
  #hosted_zone_id         = local.workspace.custom.hosted_zone_id
}

module "aws_sftp_user" {
  for_each                = { for user in local.workspace.custom.aws_sftp.users: user.name => user }
  source     = "./modules/aws_sftp_user"
  s3_bucket_name          = each.value.s3_bucket_name
  sftp_server_id          = module.aws_sftp.0.server_id
  sftp_user_name          = each.value.name
  ssh_key                 = each.value.ssh_key
  depends_on = [module.aws_sftp]
}



