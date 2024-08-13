module "grafana_prometheus_monitoring" {
  count   = try(local.workspace.grafana_prometheus_monitoring.enabled, false) ? 1 : 0
  source  = "DNXLabs/eks-grafana-prometheus/aws"
  version = "0.1.0"
  enabled = true

  settings_prometheus = {
    "alertmanager.persistentVolume.enabled"      = true
    "alertmanager.persistentVolume.storageClass" = "gp2"

    "server.persistentVolume.enabled"      = true
    "server.persistentVolume.storageClass" = "gp2"

    # "server.service.type" = "LoadBalancer" # Default to ClusterIP, uncoment to expose service.
  }
  settings_grafana = {
    "persistence.storageClassName" = "gp2"
    "persistence.enabled"          = true

    # "service.type" = "LoadBalancer" # Default to ClusterIP, uncoment to expose service.
  }
}