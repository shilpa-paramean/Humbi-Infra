module "node_termination_handler" {
  count   = try(local.workspace.node_termination_handler.enabled, false) ? 1 : 0
  source  = "DNXLabs/eks-node-termination-handler/aws"
  version = "0.1.3"
  enabled = true
}
