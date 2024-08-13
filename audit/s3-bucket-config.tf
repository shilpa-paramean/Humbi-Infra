data "aws_iam_policy_document" "s3_policy_config" {
  statement {
    sid    = "ConfigLogs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-config-${data.aws_region.current.name}/*"
    ]
  }
  statement {
    sid    = "OrgAccounts"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", try(local.workspace.logs_buckets.allow_from_account_ids,[]))
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-config-${data.aws_region.current.name}/*"
    ]
  }
  statement {
    sid    = "OrgAccountsAcl"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", try(local.workspace.logs_buckets.allow_from_account_ids, []))
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-config-${data.aws_region.current.name}"
    ]
  }
  statement {
    sid    = "ConfigLogsAcl"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-config-${data.aws_region.current.name}"
    ]
  }
}

resource "aws_s3_bucket" "config" {
  count  = try(local.workspace.logs_buckets.enabled ? 1 : 0, 0)
  bucket = "${local.workspace.org_name}-${local.workspace.account_name}-config-${data.aws_region.current.name}"
  acl    = "private"
  policy = data.aws_iam_policy_document.s3_policy_config.json

  lifecycle {
    ignore_changes = [
      versioning,
      grant
    ]
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
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

output "config_s3_bucket_name" {
  value = try(aws_s3_bucket.config[0].id, null)
}

output "config_s3_bucket_arn" {
  value = try(aws_s3_bucket.config[0].arn, null)
}