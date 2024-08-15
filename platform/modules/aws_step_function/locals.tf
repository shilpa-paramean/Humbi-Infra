# ------
# LOCALS
# ------

locals {
  name                                                = var.name
  aws_region                                          = var.aws_region
  vpc_id                                              = var.vpc_id
  # send_error_sns_topic_arn                            = var.send_error_sns_topic_arn
  job_queue                                           = var.job_queue
  job_definition                                      = var.job_definition
  subnet_ids                                          = var.subnet_ids
}
