
module "securityhub" {
  count  = try(local.workspace.securityhub.enabled ? 1 : 0, 0)
  source = "git::https://github.com/DNXLabs/terraform-aws-securityhub.git?ref=0.1.0"

  subscription_pci          = try(local.workspace.securityhub.subscriptions.pci, false)
  subscription_cis          = try(local.workspace.securityhub.subscriptions.cis, false)
  subscription_foundational = try(local.workspace.securityhub.subscriptions.foundational, false)
  members                   = try(local.workspace.securityhub.members, [])
  alarm_email               = try(local.workspace.securityhub.alarms.enabled ? try(local.workspace.securityhub.alarms.email, "") : "", "")
  alarm_slack_endpoint      = try(local.workspace.securityhub.alarms.enabled ? try(local.workspace.securityhub.alarms.slack_endpoint, "") : "", "")
}
