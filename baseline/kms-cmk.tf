data "aws_iam_policy_document" "kms_policy_cmk" {
  count = length(try(local.workspace.cmk, []))
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
      values   = try(local.workspace.cmk[count.index], "") == "ecr" ?  concat([join(",", try(local.workspace.ecr.trust_account_ids, []))], [data.aws_caller_identity.current.account_id]) :  [data.aws_caller_identity.current.account_id]
      
    }
  
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["${lower(try(local.workspace.cmk[count.index], ""))}.${data.aws_region.current.name}.amazonaws.com"]
    }
    sid = "Allow access for all principals in the account that are authorized to use the ${try(local.workspace.cmk[count.index], "service")} "
  }
}

resource "aws_kms_key" "cmk" {
  count = length(try(local.workspace.cmk, []))
  deletion_window_in_days = 30
  description             = "Customer-managed key that protects ${try(local.workspace.cmk[count.index], "service")}"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_policy_cmk[count.index].json
}

resource "aws_kms_alias" "cmk" {
  count = length(try(local.workspace.cmk, []))
  name          = "alias/cmk/${lower(try(local.workspace.cmk[count.index], "service"))}"
  target_key_id = aws_kms_key.cmk[count.index].key_id
}