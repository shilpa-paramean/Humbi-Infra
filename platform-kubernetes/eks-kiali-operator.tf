module "kiali_operator" {
  count   = try(local.workspace.kiali_operator.enabled, false) ? 1 : 0
  source  = "DNXLabs/eks-kiali-operator/aws"
  version = "0.1.1"

  enabled = true
}