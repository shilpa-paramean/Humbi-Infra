data "aws_eks_cluster" "cluster" {
  count = try(local.workspace.eks.enabled, false) ? 1 : 0
  name  = module.eks_cluster[0].cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = try(local.workspace.eks.enabled, false) ? 1 : 0
  name  = module.eks_cluster[0].cluster_id
}

# In case of not creating the cluster, this will be an incompletely configured, unused provider, which poses no problem.
provider "kubernetes" {
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""]), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
}

resource "aws_kms_key" "eks" {
  count       = try(local.workspace.eks.enabled, false) ? 1 : 0
  description = "EKS Secret Encryption Key"
}

resource "aws_iam_service_linked_role" "eks_autoscaling" {
  count            = try(local.workspace.eks.enabled, false) && try(local.workspace.eks.create_asg_iam_service_linked_role, false) ? 1 : 0
  aws_service_name = "autoscaling.amazonaws.com"
}

module "eks_cluster" {
  count  = try(local.workspace.eks.enabled, false) ? 1 : 0
  source = "terraform-aws-modules/eks/aws"

  create_eks                      = true
  version                         = "17.1.0"
  cluster_name                    = try(local.workspace.eks.name, "")
  cluster_version                 = try(local.workspace.eks.version, "")
  write_kubeconfig                = false
  enable_irsa                     = true
  cluster_enabled_log_types       = ["controllerManager"]
  cluster_iam_role_name           = "eks-cluster-${try(local.workspace.eks.name, "")}-${data.aws_region.current.name}"
  workers_role_name               = "eks-workers-${try(local.workspace.eks.name, "")}-${data.aws_region.current.name}"
  fargate_pod_execution_role_name = "eks-fargate-${try(local.workspace.eks.name, "")}-${data.aws_region.current.name}"

  cluster_endpoint_private_access = true

  subnets = data.aws_subnet_ids.private[0].ids
  vpc_id  = data.aws_vpc.selected[0].id

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks[0].arn
      resources        = ["secrets"]
    }
  ]

  node_groups = {
    nodes = {
      desired_capacity = try(local.workspace.eks.node_group.desired_capacity, 3)
      max_capacity     = try(local.workspace.eks.node_group.max_capacity, 9)
      min_capacity     = try(local.workspace.eks.node_group.min_capacity, 3)
      instance_types   = try(local.workspace.eks.node_group.instance_types, ["t3a.small", "t3.small", "t2.small"])
      capacity_type    = try(local.workspace.eks.node_group.capacity_type, "SPOT")

      launch_template_id      = aws_launch_template.default[0].id
      launch_template_version = aws_launch_template.default[0].default_version

      k8s_labels = {
        Environment = try(local.workspace.eks.name, "")
      }

      additional_tags = {
        CustomTag = "EKS ${try(local.workspace.eks.name, "")}"
      }
    }
  }

  tags = {
    "k8s.io/cluster-autoscaler/${try(local.workspace.eks.name, "")}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"                              = "TRUE"
  }

  manage_aws_auth = true

  map_roles    = try(local.workspace.eks.map_roles, [])
  map_users    = try(local.workspace.eks.map_users, [])
  map_accounts = try(local.workspace.eks.map_accounts, [])

  # Create security group rules to allow communication between pods on workers and pods in managed node groups.
  # Set this to true if you have AWS-Managed node groups and Self-Managed worker groups.
  # See https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1089

  worker_create_cluster_primary_security_group_rules = false
}

# output "eks_cluster_oidc_provider_arn" {
#   value = { for cluster_name, output in module.eks_cluster : cluster_name => output.oidc_provider_arn }
# }
