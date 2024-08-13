resource "aws_iam_user" "azure_list_roles" {
  name = "Azure-sso-list-roles"
}

resource "aws_iam_user_policy_attachment" "azure_list_roles" {
  user       = aws_iam_user.azure_list_roles.name
  policy_arn = aws_iam_policy.azure_list_roles.arn
}
