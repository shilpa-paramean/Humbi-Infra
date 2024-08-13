module "external_secrets" {
  count = try(local.workspace.external_secrets.enabled, false) ? 1 : 0

  source  = "DNXLabs/eks-external-secrets/aws"
  version = "0.1.2"
  enabled = true

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn
  secrets_aws_region               = data.aws_region.current.name

  helm_chart_repo    = try(local.workspace.external_secrets.helm_chart_repo, "https://external-secrets.github.io/kubernetes-external-secrets/")
  helm_chart_version = try(local.workspace.external_secrets.helm_chart_version, "7.2.1")
}