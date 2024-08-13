module "calico" {
  count = try(local.workspace.calico.enabled, false) ? 1 : 0

  source  = "DNXLabs/eks-calico/aws"
  version = "0.1.0"

  enabled = true
}
