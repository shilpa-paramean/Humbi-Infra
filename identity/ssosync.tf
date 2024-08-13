module "ssosync" {
  count  = try(local.workspace.ssosync.enabled, false) ? 1 : 0
  source = "./ssosync"

  enabled = true

  lambda_timeout      = try(local.workspace.ssosync.timeout, 300)
  lambda_tag          = try(local.workspace.ssosync.tag, "latest")
  schedule_expression = try(local.workspace.ssosync.schedule_expression, "rate(24 hours)")
  log_level           = try(local.workspace.ssosync.log_level, "warn")
  google_user_match   = try(local.workspace.ssosync.google_user_match, "")
  google_group_match  = try(local.workspace.ssosync.google_group_match, "")
  sync_method         = try(local.workspace.ssosync.sync_method, "groups")
  ignore_groups       = try(local.workspace.ssosync.ignore_groups, "")
  ignore_users        = try(local.workspace.ssosync.ignore_users, "")
  include_groups      = try(local.workspace.ssosync.include_groups, "")
}
