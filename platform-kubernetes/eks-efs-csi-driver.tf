module "eks_efs_csi_driver" {
  count = try(local.workspace.efs_csi_driver.enabled, false) ? 1 : 0

  source  = "DNXLabs/eks-efs-csi-driver/aws"
  version = "0.1.2"

  enabled = true
}


# # EFS creation
# resource "aws_security_group" "eks_efs_group" {
#   name        = "eks-efs-group"
#   description = "NFS access to EFS from EKS worker nodes"
#   vpc_id      = data.aws_vpc.selected.id

#   ingress {
#     description = "Allow NFS from EKS to EFS"
#     from_port   = 2049
#     to_port     = 2049
#     protocol    = "tcp"
#     cidr_blocks = [data.aws_vpc.selected.cidr_block]
#   }

#   tags = {
#     Name = "allow_nfs_eks_efs"
#   }
# }

# resource "aws_efs_file_system" "eks_fs" {
#   creation_token = "eks-dev-apps"
#   encrypted      = true

#   throughput_mode                 = "bursting"
#   provisioned_throughput_in_mibps = 0

#   tags = {
#     Name   = "eks-dev-apps"
#     Backup = false
#   }
# }

# resource "aws_efs_mount_target" "efs_target" {
#   count = length(data.aws_subnet_ids.secure.ids)

#   file_system_id = aws_efs_file_system.eks_fs.id
#   subnet_id      = element(tolist(data.aws_subnet_ids.secure.ids), count.index)

#   security_groups = [
#     aws_security_group.eks_efs_group.id
#   ]

#   lifecycle {
#     ignore_changes = [subnet_id]
#   }
# }