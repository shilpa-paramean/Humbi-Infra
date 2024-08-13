module "redis" {
  source                  = "git::https://github.com/DNXLabs/terraform-aws-elasticache.git?ref=0.6.1"

  for_each                 = { for redis in try(local.workspace.elasticache.redis, []) : redis.name => redis }
  env                      = each.value.env
  name                     = each.value.name
  redis_node_type          = each.value.redis_node_type              # Required
  redis_clusters           = try(each.value.redis_clusters, 0)       # "Number of Redis cache clusters (NODES) to create"
  multi_az_enabled         = try(each.value.multi_az_enabled, false) # For "multi_az_enabled" also need to enable "redis_failover" and update "redis_clusters" to at least 2 nodes
  redis_failover           = try(each.value.redis_failover, false)
  allowed_cidr             = try(each.value.allowed_cidr, ["127.0.0.1/32"]) # "A list of CIDRs to allow access to."
  allow_security_group_ids = try(each.value.allowed_security_groups, [])    # "A list of Security Group ID's to allow access to."
  security_group_names     = try(each.value.security_group_names, [])       # Can't be used with "allowed_security_groups" (SG_ID with SG_Name)

  vpc_id                                = data.aws_vpc.selected[0].id
  redis_maintenance_window              = try(each.value.redis_maintenance_window, "") # The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period"
  redis_port                            = try(each.value.redis_port, 6379)
  redis_snapshot_retention_limit        = try(each.value.redis_snapshot_retention_limit, 0)
  redis_snapshot_window                 = try(each.value.redis_snapshot_window, "06:30-07:30")     # "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster."
  redis_version                         = try(each.value.redis_version, "3.2.10")                  # "Whether to enable encryption in transit. Requires 3.2.6 or >=4.0 redis_version"
  redis_cluster_num_node_groups         = try(each.value.redis_cluster_num_node_groups, 1)         # 
  redis_cluster_replicas_per_node_group = try(each.value.redis_cluster_replicas_per_node_group, 1) #
  snapshot_arns                         = try(each.value.snapshot_arns, [])                        # "A single-element string list containing an Amazon Resource Name (ARN) of a Redis RDB snapshot file stored in Amazon S3. Example: arn:aws:s3:::my_bucket/snapshot1.rdb"
  snapshot_name                         = try(each.value.snapshot_name, "")                        # " The name of a snapshot from which to restore data into the new node group. Changing the snapshot_name forces a new resource"
  tags                                  = try(each.value.tags, {})
  transit_encryption_enabled            = try(each.value.transit_encryption_enabled, false)
  redis_parameters                      = try(each.value.redis_parameters, [])
  apply_immediately                     = try(each.value.apply_immediately, false) # "Specifies whether any modifications are applied immediately, or during the next maintenance window. Default is false."
  at_rest_encryption_enabled            = try(each.value.at_rest_encryption_enabled, false)
  auth_token                            = try(each.value.auth_token, null)                  # "The password used to access a password protected server. Can be specified only if transit_encryption_enabled = true. If specified must contain from 16 to 128 alphanumeric characters or symbols"
  auto_minor_version_upgrade            = try(each.value.auto_minor_version_upgrade, false) # "Specifies whether a minor engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window"
  availability_zones                    = try(each.value.availability_zones, [])
  kms_key_id                            = try(each.value.kms_key_id, "")
  notification_topic_arn                = try(each.value.notification_topic_arn, "")
  secret_method                         = try(each.value.secret_method, "ssm")
}