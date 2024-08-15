# ----
# MAIN
# ----

resource "aws_transfer_ssh_key" "this" {
  server_id = local.sftp_server_id
  user_name = local.sftp_user_name
  body      = local.ssh_key
  depends_on = [aws_transfer_user.this]
}


resource "aws_transfer_user" "this" {
  server_id = local.sftp_server_id
  user_name = local.sftp_user_name
  role      = aws_iam_role.this.arn

  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${local.s3_bucket_name}"
  }

  tags = {
    NAME = local.sftp_user_name
  }
}

resource "aws_iam_role" "this" {
  name = "${local.sftp_user_name}-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  name = "${local.sftp_user_name}-iam-policy"
  role = aws_iam_role.this.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowFullAccesstoS3",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}
