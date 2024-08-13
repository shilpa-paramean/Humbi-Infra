output "azure_list_roles_arn" {
  value = aws_iam_role.azure_list_roles.arn
}

output "azure_list_roles_user_arn" {
  value = aws_iam_user.azure_list_roles.arn
}