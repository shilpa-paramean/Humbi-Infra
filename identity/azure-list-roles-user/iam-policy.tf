
data "aws_iam_policy_document" "azure_list_roles" {
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["iam:ListRoles"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "azure_list_roles" {
  name   = "Azure-sso-list-roles-policy"
  policy = data.aws_iam_policy_document.azure_list_roles.json
}