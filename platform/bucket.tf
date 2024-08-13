resource "aws_s3_bucket" "bucket" {
  for_each      = { for bucket in try(local.workspace.buckets, []) : bucket.name => bucket }
  bucket_prefix = "${each.value.name}-${each.value.environment_name}"
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = try(each.value.kms_key_arn, "")
        sse_algorithm     = each.value.kms_key_arn != null ? "aws:kms" : "AES256"
      }
    }
  }
}
