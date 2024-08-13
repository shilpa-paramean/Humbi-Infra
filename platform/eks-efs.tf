resource "aws_security_group" "eks_efs_group" {
  count       = try(local.workspace.eks.enabled, false) && try(local.workspace.eks.efs.enabled, false) ? 1 : 0
  name        = "eks-efs-${try(local.workspace.eks.name, "")}"
  description = "NFS access to EFS from EKS worker nodes"
  vpc_id      = data.aws_vpc.selected[count.index].id

  ingress {
    description = "Allow NFS from EKS to EFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected[count.index].cidr_block]
  }

  tags = {
    Name = "eks-efs-${try(local.workspace.eks.name, "")}"
  }
}

resource "aws_efs_file_system" "eks_fs" {
  count          = try(local.workspace.eks.enabled, false) && try(local.workspace.eks.efs.enabled, false) ? 1 : 0
  creation_token = try("eks-${local.workspace.eks.name}", "")
  encrypted      = true

  tags = {
    Name   = try("eks-${local.workspace.eks.name}", "")
    Backup = true
  }
}

resource "aws_efs_mount_target" "efs_target" {
  count = (try(local.workspace.eks.enabled, false) && try(local.workspace.eks.efs.enabled, false) ? 1 : 0) * try(length(data.aws_subnet_ids.secure[0].ids), 0)

  file_system_id = aws_efs_file_system.eks_fs[0].id
  subnet_id      = element(tolist(data.aws_subnet_ids.secure[0].ids), count.index)

  security_groups = [
    aws_security_group.eks_efs_group[0].id
  ]

  lifecycle {
    ignore_changes = [subnet_id]
  }
}