module "metrics_server" {
  count              = try(local.workspace.metrics_server.enabled, false) ? 1 : 0
  source             = "DNXLabs/eks-metrics-server/aws"
  version            = "0.2.0"
  enabled            = true
  helm_chart_repo    = try(local.workspace.metrics_server.helm_chart_repo, "https://charts.helm.sh/stable/")
  helm_chart_version = try(local.workspace.metrics_server.helm_chart_version, "2.11.2")
}
