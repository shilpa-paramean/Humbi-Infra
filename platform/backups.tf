module "backups" {
  count  = local.workspace.backups.enabled ? 1 : 0
  source = "git::https://github.com/DNXLabs/terraform-aws-backup?ref=1.0.3"

  name              = "${try(local.workspace.backups.name, terraform.workspace)}-daily"
  rule_schedule     = try(local.workspace.backups.rule_schedule, "")
  vault_kms_key_arn = try(local.workspace.backups.kms_key_arn, "")
}