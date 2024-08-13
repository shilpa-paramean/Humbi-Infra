module "velero" {
  count   = try(local.workspace.velero.enabled, false) ? 1 : 0
  source  = "DNXLabs/eks-velero/aws"
  version = "0.1.2"
  enabled = true

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn
  aws_region                       = data.aws_region.current.name
  bucket_name                      = terraform.workspace
}