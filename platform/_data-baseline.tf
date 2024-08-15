data "aws_subnet_ids" "managed_node_groups_private" {
  vpc_id = data.aws_vpc.selected.0.id
  filter {
    name   = "tag:Name"
    values = [
      "${local.workspace.account_name}-subnet-private-A-${local.workspace.aws_region}",
      "${local.workspace.account_name}-subnet-private-B-${local.workspace.aws_region}",
      "${local.workspace.account_name}-subnet-private-C-${local.workspace.aws_region}"
    ]
  }
}


data "aws_subnet_ids" "managed_node_groups_secure" {
  vpc_id = data.aws_vpc.selected.0.id
  filter {
    name   = "tag:Name"
    values = [
      "${local.workspace.account_name}-subnet-secure-A-${local.workspace.aws_region}",
      "${local.workspace.account_name}-subnet-secure-B-${local.workspace.aws_region}",
      "${local.workspace.account_name}-subnet-secure-C-${local.workspace.aws_region}"
    ]
  }
}


data "archive_file" "hh_trigger" {

  type        = "zip"
  output_path = "./lambdas/hh_trigger.zip"

  source {
    content  = file("./lambdas/hh_trigger.py")
    filename = "hh_trigger.py"
  }

}

