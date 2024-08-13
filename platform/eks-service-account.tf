data "aws_iam_role" "pod_role" {
  depends_on = [module.iam_assumable_role_with_oidc_creator_daemon]
  count      = try(local.workspace.eks.enabled, false) ? 1 : 0
  name       = "${try(local.workspace.eks.environment_name, "")}-eks-pod-role"
}

resource "kubernetes_service_account" "role_service_account" {
  count = try(local.workspace.eks.enabled, false) ? 1 : 0

  depends_on = [module.iam_assumable_role_with_oidc_creator_daemon]
  metadata {
    name      = try(local.workspace.eks.service_account_role, "")
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" : "${try(data.aws_iam_role.pod_role[0].arn, "")}"
    }
  }
}

module "iam_assumable_role_with_oidc_creator_daemon" {
  depends_on                    = [aws_iam_policy.eks_pod_policy]
  count                         = try(local.workspace.eks.enabled, false) ? 1 : 0
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = "${try(local.workspace.eks.environment_name, "")}-eks-pod-role"
  provider_url                  = replace(module.eks_cluster[0].cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.eks_pod_policy[0].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:default:${try(local.workspace.eks.service_account_role, "")}"]
}

resource "aws_iam_policy" "eks_pod_policy" {
  count       = try(local.workspace.eks.enabled, false) ? 1 : 0
  name_prefix = "eks_pod_policy"
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${try(local.workspace.eks.environment_name, "")}-*",
        ]
      },
      {
        Action = [
          "sns:*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
        ]
      }
    ]
  })

}
