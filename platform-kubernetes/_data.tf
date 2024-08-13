
data "aws_eks_cluster" "cluster" {
  name = local.workspace.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.workspace.cluster_name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_role" "workers" {
  name = "eks-workers-${local.workspace.cluster_name}-${data.aws_region.current.name}"
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:EnvName"
    values = [local.workspace.account_name]
  }
}