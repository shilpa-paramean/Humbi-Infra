module "azure_list_roles_user" {
  count  = try(local.workspace.azure_list_roles_user.enabled, false) ? 1 : 0
  source = "./azure-list-roles-user"
}
