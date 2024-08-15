module "aws_step_function" {
  count      = local.workspace.custom.data-flow-baseline.aws_step_function.enabled != true ? 0 : 1
  source     = "./modules/aws_step_function"
  name       = local.workspace.custom.data-flow-baseline.aws_step_function.name
  aws_region = local.workspace.aws_region
  job_queue  = module.aws_batch.0.hh_processing_queue_arn
  job_definition = module.zip_processing_job.0.job_arn
  
  vpc_id = data.aws_vpc.selected.0.id
  subnet_ids = data.aws_subnet_ids.managed_node_groups_private.ids

  #depends_on = [
  #  module.aws_lambda_trigger,
  #  module.aws_batch  
  #]
}

