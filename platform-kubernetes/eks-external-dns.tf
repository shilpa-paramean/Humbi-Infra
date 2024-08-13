module "external_dns" {
  count = try(local.workspace.external_dns.enabled, false) ? 1 : 0

  source  = "DNXLabs/eks-external-dns/aws"
  version = "0.1.4"
  enabled = true

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn

  settings = {
    "policy" = "sync" # Modify how DNS records are sychronized between sources and providers.
  }
}
