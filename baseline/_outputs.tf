output "ssm_cmk_arn" {
  value = [ for k, v in aws_kms_alias.cmk : format("%s --> %s", v.id, aws_kms_key.cmk[k].arn) ]
}

output "ssm_cmk_v2_arn" {
  value = [ for k, v in aws_kms_alias.cmk_v2 : format("%s --> %s", v.id, aws_kms_key.cmk_v2[k].arn) ]
}

output "aws_detective_graph_arn" {
  value = try(aws_detective_graph.primary[0].graph_arn, "")
}