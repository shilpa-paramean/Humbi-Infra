
module "aws_sns" {
  for_each                = { for client in local.workspace.custom.data-flow-clients: client.name => client }

  source         = "./modules/aws_sns"
  name           = join("_",[each.value.aws_sns.name, "zip_processing_notifier"])

}

