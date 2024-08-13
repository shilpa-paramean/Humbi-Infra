data "aws_iam_policy_document" "s3_policy_logs" {
  statement {
    sid    = "CWLogs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-logs-${data.aws_region.current.name}/*"
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
      "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-logs-${data.aws_region.current.name}/*"
    ]
  }
  statement {
    sid    = "OrgAccountsAcl"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", try(local.workspace.logs_buckets.allow_from_account_ids,[]))
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-logs-${data.aws_region.current.name}"
    ]
  }
  statement {
    sid    = "CWLogsAcl"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-logs-${data.aws_region.current.name}"
    ]
  }
}

resource "aws_s3_bucket" "logs" {
  count  = try(local.workspace.logs_buckets.enabled ? 1 : 0, 0 )
  bucket = "${local.workspace.org_name}-${local.workspace.account_name}-logs-${data.aws_region.current.name}"
  acl    = "private"
  policy = data.aws_iam_policy_document.s3_policy_logs.json

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

output "logs_s3_bucket_name" {  
  value = try(aws_s3_bucket.logs[0].id, null)
}

output "logs_s3_bucket_arn" {
  value = try(aws_s3_bucket.logs[0].arn, null)
}