# resource "kubernetes_namespace" "cloudwatch" {
#   count = (local.workspace.cloudwatch_logs.enabled || local.workspace.cloudwatch_metrics.enabled) ? 1 : 0

#   metadata {
#     name = "amazon-cloudwatch"
#   }
# }
