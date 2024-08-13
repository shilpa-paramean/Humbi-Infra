module "github_runner" {
  count   = try(local.workspace.github_runner.enabled, false) ? 1 : 0
  source  = "DNXLabs/eks-github-runner/aws"
  version = "0.1.0"
  enabled = true

  cluster_name                     = local.workspace.cluster_name
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn

  github_app_app_id          = local.workspace.github_runner.github_app_app_id
  github_app_installation_id = local.workspace.github_runner.github_app_installation_id
  github_organizations       = local.workspace.github_runner.github_organizations
  github_repositories        = local.workspace.github_runner.github_repositories
  policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
  # PS: In real clients, use SSM or other external secret manager to store the private key
  github_app_private_key = <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAyhOkK16Qqd7kdqa93UWQttTujK5sCY7iduqe1maylsf2jLL/
8ZDOfbyzIoMuAQav+EwLKpYoUHHEoWJVo4O609r75oc6CpcyyhUSCRiVphJmjaET
9FJD0edh+3JnaJxnbyslYR0nromBR6NGseolQkcQxvndsIreljEnR3b39QxBl+rY
X50ktN4JTlKNrk06FAJGO3Vu6po12Z9CmQOef6rFP1CyZuQqf/gCqyah0SChKvuP
CuUnxZF9Xh9xQoZPeszURONE22s7xJIwsS0DbQjSHj5OfmiwPREh6Fo5zNr+mvCF
jeXHJL0eXEbHOg5WyacewajoBkWlh1wqbpI+iQIDAQABAoIBADr19Ca7VtZZtKty
B1/ylkDibCAcHGXFjQpJdsL0ABPCkIuJBujC6Z0CW/or8FZYTyvRdEieu3CNYWP9
PyOQogiCkpE2z5abezQ/ZZ3F0JQ+NjII17un7SXnr00gmk+JoxxqqGNnkFZ6xH/U
giITQX/PIHQOH8MNIdkMynstmTekMRIg8ray3gd9mCO4ika15VCs0dphm75OUokO
SO3OQtqzVpgqmU3kJrtHKHhfJKLCzXID52Ct+hhhghQhgVsyYNK0KMZsnPvq+NbI
coeSsglevqmDAlZNme2QzqKcJoj0ZHWD2ravzdROc5aveZjF1aZiXWZbwYqeHpY3
uM0rywECgYEA6UjQUJ344bl0NKs3CN+1r/vfJg2MVVi/75/sJ4+2TcM8OMJGYfYs
91JtG+I/GHgAPIqZblQpV6N/1pAMODhkSWtftvbtXfunzlqfxYGcJ+Blgx0wQTGh
Xtc/VTuFh8E4HnHGHXJNjem2c9nAJd6oMN/GMc/6WGAnaJBnMh27IVECgYEA3cDm
JXEUd8BuoNzThQf/BrMVuxzcnvB55fMAYTaroux9vWnu9PEqKlKnoopcuBlvbnEv
2gTRyQhliGtwn1bSQmXKaDbjaG7uqNvOQRgzhg3z7dUlxuqe4kpx968tMyRPjuzj
0tPUWrLJ8NVvaYbj04yldc95Yu3M7ojut7ixu7kCgYBnOIakBSIIjoxyeYeib4nu
0l2MctYzNU/H8VUGtDoP8mEFJEEMO2buEBSjD9qnMwG3yAPXo3mfg4KfJ6GghqMp
MU9qn5uryBwZ3FNxisXThyCjgRjG3/TtCATH68xLoxz3q5Pjl53lOxI19JVmrDxz
U7BYfhPhYrpNNAfVTv5r4QKBgQCJDQcwbMrxmATHdrNjrKV5RoVPt27C7GzqKV06
t8csUm0D+8yrpcEhlyPz2P+k6FNuNpYUcJYXYREfVwer8sTQNIj8D7BMgwMNaYv3
vzVYzJbNjsZiQe8gfFIjeii9StvAwbesPS8pPwZ/yemplqyHuo0oWqny8nWNlyOy
eHugQQKBgH9Taz2LnT1jK/J0YfwXwk0w4uoZlq6nXEmKgmEgarIGrnp77qOPMggl
XWiAKLQc7NhtjjbIucW/UPNZBYRZGzFYUlKp79RG6Ddo3n7lMXIPXenv9Apds4wH
SlNNuyL7qw8NDELVkyK4IZsl3s/YeHbdFr+MtjxVxTXIfEZHU7EF
-----END RSA PRIVATE KEY-----
EOT

}
