resource "aws_iam_role" "azure_list_roles" {
  name               = "Azure-sso-list-roles-role"
  assume_role_policy = data.aws_iam_policy_document.role_azure_list_roles.json
}

data "aws_iam_policy_document" "role_azure_list_roles" {
  statement {
    sid     = "1"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.azure_list_roles.arn]
    }
  }
}

resource "aws_iam_role_policy_attachment" "azure_list_roles_policy" {
  role       = aws_iam_role.azure_list_roles.name
  policy_arn = aws_iam_policy.azure_list_roles.arn
}
