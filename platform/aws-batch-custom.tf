module "aws_batch" {
  count      = local.workspace.custom.data-flow-baseline.aws_batch.enabled != true ? 0 : 1
  source     = "./modules/aws_batch"
  name       = local.workspace.custom.data-flow-baseline.aws_batch.name
  subnet_ids = data.aws_subnet_ids.managed_node_groups_private.ids
  vpc_id     = data.aws_vpc.selected.0.id
}



