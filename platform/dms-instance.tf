module "aws_dms_instance" {
  source   = "git::https://github.com/DNXLabs/terraform-aws-dms-replication-instance.git?ref=0.0.1"
  for_each = { for instance in try(local.workspace.dms.instance, []) : instance.replication_instance_id => instance }

  allocated_storage            = each.value.allocated_storage
  availability_zone            = each.value.availability_zone
  engine_version               = each.value.engine_version
  preferred_maintenance_window = each.value.preferred_maintenance_window
  replication_instance_class   = each.value.replication_instance_class
  replication_instance_id      = each.value.replication_instance_id

  vpc_security_group_ids = concat(
    [for cluster_name in try(each.value.ecs_cluster_names, []) : module.ecs_cluster[cluster_name].ecs_nodes_secgrp_id],
    [for client_vpn_name in try(each.value.allow_from_client_vpns, []) : data.aws_security_groups.rds_client_vpn[client_vpn_name].ids[0]]
  )

  replication_subnet_group_id = "dms-replication-subnet-group"
  subnet_ids                  = data.aws_subnet_ids.private[0].ids
}