module "cloudwatch_logs" {
  count = try(local.workspace.cloudwatch_logs.enabled, false) ? 1 : 0

  source  = "DNXLabs/eks-cloudwatch-logs/aws"
  version = "0.1.4"
  enabled = true

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn
  worker_iam_role_name             = data.aws_iam_role.workers.id
  region                           = data.aws_region.current.name

  helm_chart_repo    = try(local.workspace.cloudwatch_logs.helm_chart_repo, "https://aws.github.io/eks-charts")
  helm_chart_version = try(local.workspace.cloudwatch_logs.helm_chart_version, "0.1.7")
}
