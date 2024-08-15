module "zip_processing_job" {
  count                = local.workspace.custom.data-flow-baseline.zip_processing_job.enabled != true ? 0 : 1
  source                        = "./modules/aws_batch_job"
  job_name                      = "zip_processing_job"
  job_role_arn                  = module.aws_batch.0.hh_batchjob_role_arn
  execution_role_arn            = module.aws_batch.0.hh_batchjob_role_arn
  image                         = "public.ecr.aws/amazonlinux/amazonlinux:latest"
  memory                        = 4096
  vcpu                          = 2
}


