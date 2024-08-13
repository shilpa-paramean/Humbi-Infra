module "nginx_ingress_controller" {
  source                  = "git::https://github.com/DNXLabs/terraform-aws-eks-generic-chart.git"
  count                   = try(local.workspace.nginx_ingress_controller.enabled, false) ? 1 : 0
  enabled                 = true
  helm_chart_name         = "ingress-nginx"
  helm_chart_release_name = "ingress-nginx"
  helm_chart_version      = "4.0.13"
  helm_chart_repo         = "https://kubernetes.github.io/ingress-nginx"
  namespace               = "ingress-nginx"

  settings = {
    "controller" = {
      "kind" = "DaemonSet"
      "service" = {
        "annotations" = {
          "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"               = "https"
          "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"        = "http"
          "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"                = try(local.workspace.nginx_ingress_controller.aws-load-balancer-ssl-cert, "")
          "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy"  = try(local.workspace.nginx_ingress_controller.aws-load-balancer-ssl-negotiation-policy, "")
          "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = try(local.workspace.nginx_ingress_controller.aws-load-balancer-connection-idle-timeout, "")
          # elb logs to s3
          "service.beta.kubernetes.io/aws-load-balancer-access-log-enabled" = try(local.workspace.nginx_ingress_controller.aws-load-balancer-access-log-enabled, "")
          "service.beta.kubernetes.io/aws-load-balancer-access-log-emit-interval"    = try(local.workspace.nginx_ingress_controller.aws-load-balancer-access-log-emit-interval, "")
          "service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-name"   = try(local.workspace.nginx_ingress_controller.aws-load-balancer-access-log-s3-bucket-name, "")
          "service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-prefix" = try(local.workspace.nginx_ingress_controller.aws-load-balancer-access-log-s3-bucket-prefix, "")
        }
        "targetPorts" = {
          "https" = 80
        }
        "externalTrafficPolicy" = "Local"
        "stats" = {
          "enabled" = "true"
        }
      }
      "config" = {
        "server-tokens"          = "false"
        "use-forwarded-headers"  = "true"
        "limit-req-status-code"  = "429"
        "limit-conn-status-code" = "429"
      }
      "replicaCount" = try(local.workspace.nginx_ingress_controller.replicaCount, "")
      "resources" = {
        "requests" = {
          "cpu"    = try(local.workspace.nginx_ingress_controller.requests.cpu, "")
          "memory" = try(local.workspace.nginx_ingress_controller.requests.memory, "")
        }
        "limits" = {
          "memory" = try(local.workspace.nginx_ingress_controller.limits.memory, "")
        }
      }
      "admissionWebhooks" = {
        "enabled"        = "false"
        "timeoutSeconds" = "30"
      }
    }
  }
}