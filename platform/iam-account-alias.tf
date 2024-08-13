resource "aws_iam_account_alias" "default" {
  count         = try(local.workspace.iam_account_alias, "") != "" ? 1 : 0
  account_alias = try(local.workspace.iam_account_alias, local.workspace.aws_account_id)
}