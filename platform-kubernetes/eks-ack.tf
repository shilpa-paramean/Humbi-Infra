module "ack" {
  count = try(local.workspace.ack.enabled, false) ? 1 : 0

  source  = "DNXLabs/eks-ack/aws"
  version = "0.2.0"
  enabled = true

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn
  aws_region                       = data.aws_region.current.name

  helm_services = [
    {
      name       = "s3"
      policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
      settings   = {}
    },
    {
      name       = "sns"
      policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
      settings   = {}
    },
    {
      name       = "sfn"
      policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
      settings   = {}
    },
    {
      name       = "elasticache"
      policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
      settings   = {}
    },
    {
      name       = "ecr"
      policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
      settings   = {}
    },
    {
      name       = "dynamodb"
      policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
      settings   = {}
    },
    {
      name       = "apigatewayv2"
      policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
      settings   = {}
    }
  ]
}