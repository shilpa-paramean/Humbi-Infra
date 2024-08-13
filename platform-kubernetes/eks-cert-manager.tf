module "cert_manager" {
  count = try(local.workspace.cert_manager.enabled, false) ? 1 : 0

  source  = "DNXLabs/eks-cert-manager/aws"
  version = "0.3.3"
  enabled = true

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn

  dns01        = try(local.workspace.cert_manager.dns01, [])
  http01       = try(local.workspace.cert_manager.http01, [])
  certificates = try(local.workspace.cert_manager.certificates, [])

  # dns01 = [
  #   {
  #     name           = "letsencrypt-prod"
  #     namespace      = "default"
  #     kind           = "ClusterIssuer"
  #     dns_zone       = "example.com"
  #     region         = "us-east-1" # data.aws_region.current.name
  #     secret_key_ref = "letsencrypt-prod"
  #     acme_server    = "https://acme-v02.api.letsencrypt.org/directory"
  #     acme_email     = "your@email.com"
  #   }
  # ]

  # In case you want to use HTTP01 challenge method uncomment this section
  # and comment dns01 variable
  # http01 = [
  #   {
  #     name           = "letsencrypt-staging"
  #     kind           = "ClusterIssuer"
  #     ingress_class  = "nginx"
  #     secret_key_ref = "letsencrypt-staging"
  #     acme_server    = "https://acme-staging-v02.api.letsencrypt.org/directory"
  #     acme_email     = "your@email.com"
  #   },
  #   {
  #     name           = "letsencrypt-prod"
  #     kind           = "ClusterIssuer"
  #     ingress_class  = "nginx"
  #     secret_key_ref = "letsencrypt-prod"
  #     acme_server    = "https://acme-v02.api.letsencrypt.org/directory"
  #     acme_email     = "your@email.com"
  #   }
  # ]

  # In case you want to create certificates uncomment this block
  # certificates = [
  #   {
  #     name           = "example-com"
  #     namespace      = "default"
  #     kind           = "ClusterIssuer"
  #     secret_name    = "example-com-tls"
  #     issuer_ref     = "letsencrypt-prod"
  #     dns_name       = "*.example.com"
  #   }
  # ]
}