module "argocd" {
  count = try(local.workspace.argocd.enabled, false) ? 1 : 0

  source  = "DNXLabs/eks-argocd/aws"
  version = "0.3.1"

  enabled = true
}


resource "kubectl_manifest" "argocd_repository" {
  for_each = { for repository in try(local.workspace.argocd.repositories, {}) : repository.name => repository }

  yaml_body = templatefile("${path.module}/templates/argocd-configmap.tpl.yaml", {
    repo_name    = each.value.name
    repourl      = each.value.repo_url
    type         = each.value.type
  })

  wait = true
  depends_on = [
    module.argocd
  ]
}

resource "kubectl_manifest" "argocd_application" {
  for_each = { for application in try(local.workspace.argocd.applications, {}) : application.name => application }
  yaml_body = templatefile("${path.module}/templates/argocd-application.tpl.yaml", {
    name                  = each.value.name
    source_repo_url       = each.value.repo_url
    source_targetRevision = each.value.targetRevision
    source_path           = each.value.path
  })
  wait = true
  depends_on = [
    module.argocd,
    kubectl_manifest.argocd_repository
  ]
}