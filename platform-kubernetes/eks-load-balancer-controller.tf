module "load_balancer_controller" {
  count   = try(local.workspace.load_balancer_controller.enabled, false) ? 1 : 0
  source  = "DNXLabs/eks-lb-controller/aws"
  version = "0.4.0"
  enabled = true

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn
}
