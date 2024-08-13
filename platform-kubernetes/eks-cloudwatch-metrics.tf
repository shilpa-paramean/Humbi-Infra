module "cloudwatch_metrics" {
  count = try(local.workspace.cloudwatch_metrics.enabled, false) ? 1 : 0

  source  = "DNXLabs/eks-cloudwatch-metrics/aws"
  version = "0.1.1"
  enabled = true

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn
  worker_iam_role_name             = data.aws_iam_role.workers.id
}
