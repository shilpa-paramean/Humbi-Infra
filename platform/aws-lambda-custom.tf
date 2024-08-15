module "aws_lambda_trigger" {
  count  = local.workspace.custom.data-flow-baseline.aws_lambda_trigger.enabled != true ? 0 : 1
  source = "./modules/aws_lambda"
  name   = local.workspace.custom.data-flow-baseline.aws_lambda_trigger.name
  region = local.workspace.aws_region
  vpc_id                  = data.aws_vpc.selected.0.id
  private_subnet_ids      = data.aws_subnet_ids.managed_node_groups_private.ids
  lambda_source_code_hash = data.archive_file.hh_trigger.output_base64sha256
  filename                = "hh_trigger.zip"
  #lambda_layers           = ["${aws_lambda_layer_version.base-layer.arn}"]
  runtime                 = "python3.9"
  timeout                 = 30
  handler                 = "hh_trigger.lambda_handler"
  lambda_environment_variables = {
    STATE_MACHINE_ARN = module.aws_step_function.0.state_machine_arn
    REGION = local.workspace.aws_region
    ENV = local.workspace.custom.data-flow-baseline.aws_lambda_trigger.env
  }
}

