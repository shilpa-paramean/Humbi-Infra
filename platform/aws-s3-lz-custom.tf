
module "aws_s3_lz" {
  for_each                = { for client in local.workspace.custom.data-flow-clients: client.name => client  }
  source                = "./modules/aws_s3"
  s3_bucket_name = each.value.aws_s3_lz.name
  #s3_bucket_name        = local.workspace.custom.aws_s3_lz.name
  #s3_versioning_enabled = false
  account_id            = local.workspace.aws_account_id
#  providers = {
#    aws.primary = aws.primary
#    aws.secondary = aws.secondary
#  }

}

module "aws_s3_lz_archive" {
  for_each                = { for client in local.workspace.custom.data-flow-clients: client.name => client }
  source                = "./modules/aws_s3"
  s3_bucket_name = join("-", [each.value.aws_s3_lz.name, "archive"])
  #s3_bucket_name        = local.workspace.custom.aws_s3_lz.name
  #s3_versioning_enabled = false
  account_id            = local.workspace.aws_account_id
#  providers = {
#    aws.primary = aws.primary
#    aws.secondary = aws.secondary
#  }

}


resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each                = {  for client in local.workspace.custom.data-flow-clients: client.name => client }

  bucket =  each.value.aws_s3_lz.name

  lambda_function {
    lambda_function_arn = module.aws_lambda_trigger.0.lambda_arn 
    events              = ["s3:ObjectCreated:*"]
    #filter_prefix       = "${var.cluster_name}/somepath/"
    #filter_suffix       = ".txt"
  }

}

resource "aws_lambda_permission" "test" {
  for_each                = {  for client in local.workspace.custom.data-flow-clients: client.name => client }

  statement_id  = "AllowS3Invoke-${each.value.aws_s3_lz.name}"
  action        = "lambda:InvokeFunction"
  function_name = local.workspace.custom.data-flow-baseline.aws_lambda_trigger.name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${each.value.aws_s3_lz.name}"
  depends_on = [module.aws_lambda_trigger]

}

