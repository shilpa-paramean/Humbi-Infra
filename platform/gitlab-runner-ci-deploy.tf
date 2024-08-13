module "gitlab_runner_ci_deploy" {
  count  = local.workspace.gitlab_runner.ci_deploy.enabled ? 1 : 0
  source = "git::https://github.com/DNXLabs/terraform-aws-gitlab-runner.git?ref=4.18.1-dnx2"

  aws_region     = data.aws_region.current.name
  environment    = try(local.workspace.gitlab_runner.ci_deploy.environment, "gitlab-ci-deploy")
  ssh_public_key = local_file.gitlab_ci_deploy_public_ssh_key[0].content

  vpc_id                            = data.aws_vpc.selected[0].id
  subnet_ids_gitlab_runner          = data.aws_subnet_ids.private[0].ids
  subnet_id_runners                 = sort(data.aws_subnet_ids.private[0].ids)[0]
  runners_name                      = try(local.workspace.gitlab_runner.ci_deploy.name, "ci-deploy")
  runners_image                     = "19.03.13"
  runners_gitlab_url                = try(local.workspace.gitlab_runner.ci_deploy.gitlab_url, "https://gitlab.com")
  runners_use_private_address       = false
  docker_machine_instance_type      = try(local.workspace.gitlab_runner.ci_deploy.docker_machine_instance_type, "m4.large")
  runners_iam_instance_profile_name = "CIDeployInstanceProfile"
  enable_runner_ssm_access          = true
  cache_bucket_prefix               = "ci-deploy-"

  secure_parameter_store_runner_token_key = "gitlab-runner-token"

  gitlab_runner_registration_config = {
    registration_token = try(local.workspace.gitlab_runner.ci_deploy.registration_token, "")
    tag_list           = "${local.workspace["org_name"]}_runner_ci, docker"
    description        = "runner for ci/cd"
    locked_to_project  = "true"
    run_untagged       = "false"
    maximum_timeout    = "3600"
  }

  runners_off_peak_timezone   = try(local.workspace.gitlab_runner.ci_deploy.runners.off_peak_timezone, "Australia/Sydney")
  runners_off_peak_idle_count = try(local.workspace.gitlab_runner.ci_deploy.runners.off_peak_idle_count, 0)
  runners_off_peak_idle_time  = try(local.workspace.gitlab_runner.ci_deploy.runners.off_peak_idle_time, 60)
  cache_expiration_days       = 10
  # working 9 to 5
  runners_off_peak_periods = try(local.workspace.gitlab_runner.ci_deploy.runners.off_peak_periods, "[\"* * 0-9,17-23 * * mon-fri *\", \"* * * * * sat,sun *\"]")
}

resource "tls_private_key" "gitlab_ci_deploy_ssh" {
  count     = local.workspace.gitlab_runner.ci_deploy.enabled ? 1 : 0
  algorithm = "RSA"
}

resource "local_file" "gitlab_ci_deploy_public_ssh_key" {
  count    = local.workspace.gitlab_runner.ci_deploy.enabled ? 1 : 0
  content  = tls_private_key.gitlab_ci_deploy_ssh[0].public_key_openssh
  filename = "generated/gitlab_ci_deploy_id_rsa.pub"
}

resource "local_file" "gitlab_ci_deploy_private_ssh_key" {
  count    = local.workspace.gitlab_runner.ci_deploy.enabled ? 1 : 0
  content  = tls_private_key.gitlab_ci_deploy_ssh[0].private_key_pem
  filename = "generated/gitlab_ci_deploy_id_rsa"
}

resource "null_resource" "gitlab_ci_deploy_file_permission" {
  count      = local.workspace.gitlab_runner.ci_deploy.enabled ? 1 : 0
  depends_on = [local_file.gitlab_ci_deploy_private_ssh_key[0]]
  provisioner "local-exec" {
    command = format("chmod 400 %s", "generated/gitlab_ci_deploy_id_rsa")
  }
}