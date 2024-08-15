{
  "Version": "2012-10-17",
  "Id": "kms-key-policy",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::${account_id}:root"},
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::${account_id}:role/hh_batchjob_role"},
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::${account_id}:role/aws_batch_service_role"},
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
