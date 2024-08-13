data "aws_iam_policy_document" "assume_auditor_iam" {
  count = try(local.workspace.iam_role_auditor.enabled && local.workspace.iam_role_auditor.trust_type == "iam" ? 1 : 0, 0)
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [try(local.workspace.iam_role_auditor.iam_principal_arn, "")]
    }

  }
}

data "aws_iam_policy_document" "assume_auditor_saml" {
  count = try(local.workspace.iam_role_auditor.enabled && local.workspace.iam_role_auditor.trust_type == "saml" ? 1 : 0, 0)

  statement {
    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type        = "Federated"
      identifiers = try([try(local.workspace.iam_role_auditor.saml_provider_arn)], [""])
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }
}

resource "aws_iam_role" "auditor" {
  count              = try(local.workspace.iam_role_auditor.enabled ? 1 : 0, 0)
  name               = "Auditor"
  assume_role_policy = try(local.workspace.iam_role_auditor.trust_type == "saml" ? data.aws_iam_policy_document.assume_auditor_saml[0].json : data.aws_iam_policy_document.assume_auditor_iam[0].json, "")  

  inline_policy {
    name = "s3_read_logs"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["s3:GetObject*", "s3:List*"]
          Effect   = "Allow"
          Resource = "arn:aws:s3:::${local.workspace.org_name}-${local.workspace.account_name}-*"
        },
        {
          Action   = ["kms:List*", "kms:Get*", "kms:Describe*", "kms:Decrypt"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "security_audit" {
  count      = try(local.workspace.iam_role_auditor.enabled ? 1 : 0, 0)
  role       = aws_iam_role.auditor[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "securityhub" {
  count      = try(local.workspace.iam_role_auditor.enabled ? 1 : 0, 0)
  role       = aws_iam_role.auditor[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSSecurityHubFullAccess"
}


resource "aws_iam_role_policy_attachment" "guardduty" {
  count      = try(local.workspace.iam_role_auditor.enabled ? 1 : 0, 0)
  role       = aws_iam_role.auditor[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonGuardDutyFullAccess"
}
