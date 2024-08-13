provider "aws" {
  region = local.workspace.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${local.workspace.aws_account_id}:role/${local.aws_role}"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.workspace.aws_account_id}:role/${local.aws_role}"
  }
}

provider "aws" {
  region = "ap-southeast-2"
  alias  = "automation"
}

locals {
  stack_name = "platform"
  client     = element(split("-", terraform.workspace), 0)
  workspace  = yamldecode(file("./.workspaces/${terraform.workspace}.yaml"))
  aws_role   = "InfraDeployAccess"
}