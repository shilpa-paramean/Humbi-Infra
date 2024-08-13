data "aws_iam_policy_document" "policy_set_ecs_default" {
  count = contains(var.policy_sets, "ECS_DEFAULT") ? 1 : 0
  statement {
    sid = "staticapps"
    actions = [
      "s3:*",
      "cloudfront:CreateInvalidation",
    ]
    resources = ["*"]
  }
  statement {
    sid = "ecsecr"
    actions = [
      "ecs:Describe*",
      "ecs:List*",
      "ecs:RunTask",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "codedeploy:CreateDeployment",
      "codedeploy:Get*",
      "codedeploy:List*",
      "codedeploy:ContinueDeployment",
      "codedeploy:StopDeployment",
      "codedeploy:RegisterApplicationRevision",
      "ecr:*",
    ]
    resources = ["*"]
  }
  statement {
    sid = "eks"
    actions = [
      "eks:Describe*",
      "eks:List*",
      "eks:UpdateClusterConfig"
    ]
    resources = ["*"]
  }
  statement {
    sid = "elb"
    actions = [
      "elasticloadbalancing:Describe*",
    ]
    resources = ["*"]
  }
  statement {
    sid = "ssm"
    actions = [
      "ssm:List*",
      "ssm:Describe*",
      "ssm:Get*"
    ]
    resources = ["*"]
  }
  statement {
    sid = "logs"
    actions = [
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogDelivery",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults",
      "logs:FilterLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:TestMetricFilter",
    ]
    resources = ["*"]
  }
  statement {
    sid = "ecspassrole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/ecs-task-*"
    ]
  }
}

resource "aws_iam_policy" "ecs_default" {
  count = contains(var.policy_sets, "ECS_DEFAULT") ? 1 : 0
  name   = "ci-deploy-ecs-default"
  policy = data.aws_iam_policy_document.policy_set_ecs_default[0].json
}

resource "aws_iam_role_policy_attachment" "policy_set_ecs_default" {
  count      = contains(var.policy_sets, "ECS_DEFAULT") ? 1 : 0
  role       = aws_iam_role.ci_deploy_access.name
  policy_arn = aws_iam_policy.ecs_default[0].arn
}