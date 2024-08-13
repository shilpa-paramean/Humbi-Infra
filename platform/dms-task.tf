module "aws_dms_replication_task" {
  source   = "git::https://github.com/DNXLabs/terraform-aws-dms-replication-task.git?ref=0.0.3"
  for_each = { for task in try(local.workspace.dms.task, []) : task.replication_task_id => task }

  cdc_start_time            = each.value.cdc_start_time
  migration_type            = each.value.migration_type
  replication_instance_arn  = each.value.replication_instance_arn
  replication_task_id       = each.value.replication_task_id
  replication_task_settings = data.template_file.read_replication_task_settings[each.value.replication_task_id].rendered
  source_endpoint_arn       = each.value.source_endpoint_arn
  target_endpoint_arn       = each.value.target_endpoint_arn
  table_mappings            = data.template_file.read_table_mappings[each.value.replication_task_id].rendered
  environment_name          = local.workspace.account_name
}
