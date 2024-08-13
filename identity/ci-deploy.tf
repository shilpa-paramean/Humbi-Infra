
locals {
  ci_deploy_access_trust_arns = concat(
    # [
    #   try(module.ci_deploy[0].ci_deploy_ec2_role_arn, ""),
    #   try(module.ci_deploy[0].ci_deploy_role_arn, ""),
    #   try(module.ci_deploy[0].ci_deploy_user_arn, ""),
    # ],
    ["arn:aws:iam::${local.workspace.aws_account_id}:root"],
    formatlist("arn:aws:iam::%s:root", local.workspace.ci_deploy_access.trust_account_ids),
    local.workspace.ci_deploy_access.trust_arns
  )
}

module "ci_deploy_access" {
  count  = local.workspace.ci_deploy_access.enabled ? 1 : 0
  source = "./ci-deploy-access-role"

  trust_arns                  = compact(local.ci_deploy_access_trust_arns)
  custom_policy               = try(local.workspace.ci_deploy_access.custom_policy, {})
  policy_sets                 = try(local.workspace.ci_deploy_access.policy_sets, ["ECS_DEFAULT"])
  cf_deploy_custom_policy     = try(local.workspace.ci_deploy_access.cf_deploy_custom_policy, null)
  ci_deploy_custom_policy     = try(local.workspace.ci_deploy_access.ci_deploy_custom_policy, null)
  serverless_app_prefix       = try(local.workspace.ci_deploy_access.serverless_app_prefix, "")
  serverless_deploy_role_name = try(local.workspace.ci_deploy_access.serverless_deploy_role_name, "CloudFormationDeploy")
}

output "ci_deploy_access_role_arn" {
  value = try(module.ci_deploy_access[0].ci_deploy_access_role_arn, "")
}

output "ci_deploy_access_policies" {
  value = try(module.ci_deploy_access[0].policies, {})
}

module "ci_deploy" {
  count  = local.workspace.ci_deploy.enabled ? 1 : 0
  source = "./ci-deploy"

  create_user             = local.workspace.ci_deploy.create_user
  create_instance_profile = local.workspace.ci_deploy.create_instance_profile
  saml_provider_arn       = local.saml_provider_arn
}

output "ci_deploy_ec2_role_arn" {
  value = try(module.ci_deploy[0].ci_deploy_ec2_role_arn, "")
}
output "ci_deploy_instance_profile_arn" {
  value = try(module.ci_deploy[0].ci_deploy_instance_profile_arn, "")
}
output "ci_deploy_role_arn" {
  value = try(module.ci_deploy[0].ci_deploy_role_arn, "")
}
output "ci_deploy_saml_role" {
  value = try(module.ci_deploy[0].ci_deploy_saml_role, "")
}
output "ci_deploy_user_arn" {
  value = try(module.ci_deploy[0].ci_deploy_user_arn, "")
}
