# ----
# DATA
# ----

data "aws_iam_policy_document" "cloudwatch_role_policy_document" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }
}

data "archive_file" "hh_trigger" {

  type        = "zip"
  output_path = "./lambdas/hh_trigger.zip"

  source {
    content  = file("./lambdas/hh_trigger.py")
    filename = "hh_trigger.py"
  }

}
