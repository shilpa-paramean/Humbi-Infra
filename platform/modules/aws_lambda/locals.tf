# ------
# LOCALS
# ------

locals {
  name                         = var.name
  region                       = var.region
  vpc_id                       = var.vpc_id
  private_subnet_ids           = var.private_subnet_ids
  lambda_environment_variables = var.lambda_environment_variables
  lambda_source_code_hash      = var.lambda_source_code_hash
  runtime                      = var.runtime
  timeout                      = var.timeout
  handler                      = var.handler
  lambda_layers                = var.lambda_layers
  filename                     = var.filename
}
