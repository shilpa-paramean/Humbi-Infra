module "eks_dashboard" {
  count   = try(local.workspace.dashboard.enabled, false) ? 1 : 0
  source  = "DNXLabs/eks-dashboard/aws"
  version = "0.2.0"
  enabled = true

  sample_user_enabled = false
}

output "dashboard_url" {
  value = try(module.eks_dashboard[0].dashboard_url, "")
}