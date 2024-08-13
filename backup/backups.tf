module "backups" {
  source = "git::https://github.com/DNXLabs/terraform-aws-backup?ref=2.0.0"

  for_each = { 
    for backup in try(local.workspace.backups, []) : backup.name => backup 
    if try(backup.enabled, false) 
  }

  account_type      = local.workspace.account_type
  name              = "${try(each.value.name, terraform.workspace.account_name)}-daily"
  rule_schedule     = try(each.value.rule_schedule, "")
  vault_kms_key_arn = try(each.value.kms_key_arn, "")
  vault_policy      = (local.workspace.account_type == local.account_type.backup 
    ? try(data.aws_iam_policy_document.cross_account_copy_policy[0].json, "") 
    : try(data.aws_iam_policy_document.allow_copy_data_back_into_account_policy[each.key].json, "") )

  enable_aws_backup_vault_notifications = try(local.workspace.notifications.enabled, false)
  vault_notification_sns_topic_arn      = try(local.workspace.notifications.enabled, false) ? try(module.notifications[0].aws_sns_topic_arn, "") : ""
  backup_vault_events                   = try(each.value.vault_events, ["BACKUP_JOB_FAILED", "COPY_JOB_FAILED"])

  rule_copy_action_destination_vault = {
    copy_action = try(each.value.copy_action, {})
  }

  depends_on = [module.notifications[0]]
}