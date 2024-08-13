module "istio_operator" {
  count   = try(local.workspace.istio_operator.enabled, false) ? 1 : 0
  source  = "DNXLabs/eks-istio-operator/aws"
  version = "0.1.0"

  enabled = true
}