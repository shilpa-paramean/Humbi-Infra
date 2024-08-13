
resource "aws_iam_policy" "serverless_advanced" {
  count = contains(var.policy_sets, "SERVERLESS_ADVANCED") ? 1 : 0
  name  = "ci-deploy-serverless-advanced"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DelegateToCloudfrontRole"
        Effect   = "Allow"
        Action   = ["cloudfront:*"]
        Resource = ["*"]
      },
      {
        Sid      = "DelegateToAppSyncRole"
        Effect   = "Allow"
        Action   = ["appsync:*"]
        Resource = ["arn:aws:appsync:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:apis/*"]
      },
      {
        Sid      = "DelegateToLambdaRole"
        Effect   = "Allow"
        Action   = ["lambda:*"]
        Resource = ["arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"]
      },
      {
        Sid      = "DelegateToApigatewayRole"
        Effect   = "Allow"
        Action   = ["apigateway:*"]
        Resource = [
          "arn:aws:apigateway:${data.aws_region.current.name}::/apis/*",
          "arn:aws:apigateway:${data.aws_region.current.name}::/domainnames/*",
        ]
      },
      {
        Sid      = "DelegateToCloudFormationRole"
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.serverless_deploy_role_name}"] # TODO: FIX
      },
      {
        Sid      = "ValidateTemplate"
        Effect   = "Allow"
        Action   = ["cloudformation:ValidateTemplate"]
        Resource = ["*"]
      },
      {
        Sid      = "AdvancedPermission"
        Effect   = "Allow"
        Action   = [      
          "ssm:*",
          "cloudformation:*",
          "apigateway:*",
          "logs:*"
                  ]

        Resource = ["*"]
      },
      {
        Sid    = "ExecuteCloudFormation"
        Effect = "Allow"
        Action = [
          "cloudformation:CreateChangeSet",
          "cloudformation:CreateStack",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeChangeSet",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResource",
          "cloudformation:DescribeStackResources",
          "cloudformation:DescribeStacks",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:ListStackResources",
          "cloudformation:SetStackPolicy",
          "cloudformation:UpdateStack",
          "cloudformation:UpdateTerminationProtection",
          "cloudformation:GetTemplate",
        ]
        Resource = ["${aws_iam_role.cloudformation_deploy.arn}"]
      },
      {
        Sid    = "ReadLambda"
        Effect = "Allow"
        Action = [
          "lambda:Get*",
          "lambda:List*",
        ]
        Resource = ["*"]
      },
      {
        Sid    = "ManageDeploymentBucket"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketAcl",
          "s3:GetEncryptionConfiguration",
          "s3:PutEncryptionConfiguration",
          "s3:GetBucketLocation",
        ]
        Resource = ["arn:aws:s3:::${var.serverless_app_prefix}*"]
      },
      {
        Sid      = "ListS3"
        Effect   = "Allow"
        Action   = ["s3:List*"]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_set_serverless_advanced" {
  count      = contains(var.policy_sets, "SERVERLESS_ADVANCED") ? 1 : 0
  role       = aws_iam_role.ci_deploy_access.name
  policy_arn = aws_iam_policy.serverless_advanced[0].arn
}