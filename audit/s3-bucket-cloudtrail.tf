
data "aws_iam_policy_document" "s3_policy_cloudtrail" {
  statement {
    sid    = "CloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-cloudtrail-${data.aws_region.current.name}"]
  }
  statement {
    sid    = "CloudTrailWriteMaster"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = formatlist(
      "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-cloudtrail-${data.aws_region.current.name}/AWSLogs/%s/*",
      [
        data.aws_organizations_organization.current.master_account_id,
        data.aws_organizations_organization.current.id
      ]
    )
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
  statement {
    sid    = "CloudTrailWriteAccounts"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = formatlist(
      "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-cloudtrail-${data.aws_region.current.name}/AWSLogs/%s/*",
      try(local.workspace.logs_buckets.allow_from_account_ids,[])
    )
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket" "cloudtrail" {
  count  = try(local.workspace.logs_buckets.enabled ? 1 : 0, 0 )
  bucket = "${local.workspace.org_name}-${local.workspace.account_name}-cloudtrail-${data.aws_region.current.name}"
  acl    = "private"
  policy = data.aws_iam_policy_document.s3_policy_cloudtrail.json

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id      = "ARCHIVING"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = try(local.workspace.logs_buckets.transition_to_glacier_in_days, 0)
      storage_class = "GLACIER"
    }
  }
}

output "cloutrail_s3_bucket_name" {
  value = try(aws_s3_bucket.cloudtrail[0].id, null)
}

output "cloutrail_s3_bucket_arn" {
  value = try(aws_s3_bucket.cloudtrail[0].arn, null)
}