data "aws_iam_policy_document" "kms_policy_cmk_v2" {
  for_each = { for key_name, v in try(local.workspace.cmk_v2, []): v.name => v }
  statement {
    sid    = "Allow direct access to key metadata to the account"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = each.key == "ecr" ?  concat([join(",", try(local.workspace.ecr.trust_account_ids, []))], [data.aws_caller_identity.current.account_id]) :  [data.aws_caller_identity.current.account_id]
      
    }
  
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["${lower(each.key)}.${data.aws_region.current.name}.amazonaws.com"]
    }
    sid = "Allow access for all principals in the account that are authorized to use the ${each.key} service"
  }
}

resource "aws_kms_key" "cmk_v2" {
  for_each                = { for key_name, v in try(local.workspace.cmk_v2, []): v.name => v }
  deletion_window_in_days = 30
  description             = "Customer-managed key that protects ${each.key} service"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_policy_cmk_v2[each.key].json
}

resource "aws_kms_alias" "cmk_v2" {
  for_each      = { for k, v in try(local.workspace.cmk_v2, []): v.name => v }
  name          = "alias/cmk/${lower(each.key)}"
  target_key_id = aws_kms_key.cmk_v2[each.key].key_id
}