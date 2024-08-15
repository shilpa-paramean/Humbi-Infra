module "aws_s3_cz" {
  for_each                = { for client in local.workspace.custom.data-flow-clients: client.name => client }
#  providers = {
#    aws.primary = aws.primary
#    aws.secondary = aws.secondary
#  }
  source                = "./modules/aws_s3"
  s3_bucket_name        = each.value.aws_s3_cz.name
  account_id            = local.workspace.aws_account_id
  #s3_versioning_enabled = false
}

