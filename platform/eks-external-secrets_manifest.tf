# Generate SSM Paramters and External Secrets for the apps

provider "kubernetes-alpha" {
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""]), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
}

resource "kubernetes_manifest" "externalStrings" {
  depends_on = [module.eks_cluster]
  provider   = kubernetes-alpha

  for_each = toset(try(local.workspace.eks.externalstrings, []))
  manifest = {
    apiVersion = "kubernetes-client.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = replace(lower(each.key), "_", "-")
      namespace = "default"
    }
    spec = {
      backendType = "systemManager"
      data = [{
        key  = "/app/${try(local.workspace.eks.environment_name, "")}/${each.key}"
        name = "${each.key}"
      }]
    }
  }
}


resource "kubernetes_manifest" "externalSecretsStrings" {
  depends_on = [module.eks_cluster]
  provider   = kubernetes-alpha

  for_each = toset(try(local.workspace.eks.externalsecured_strings, []))
  manifest = {
    apiVersion = "kubernetes-client.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = replace(lower(each.key), "_", "-")
      namespace = "default"
    }
    spec = {
      backendType = "systemManager"
      data = [{
        key  = "/app/${try(local.workspace.eks.environment_name, "")}/${each.key}"
        name = "${each.key}"
      }]
    }
  }
}