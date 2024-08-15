# ----
# MAIN
# ----

resource "aws_s3_bucket" "source_bucket" {
  bucket = local.s3_bucket_name
  acl    = "private"
#  provider = "aws.primary"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.source_bucket.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  #replication_configuration {
  #  role = aws_iam_role.replication.arn
  #
  #  rules {
  #    status = "Enabled"
  #    destination {
  #      bucket  = "${aws_s3_bucket.replica_bucket.arn}"
  #      storage_class = "STANDARD"
  #      replica_kms_key_id = "${aws_kms_key.replica_bucket.arn}"
  #    }
  #    source_selection_criteria {
  #      sse_kms_encrypted_objects {
  #        enabled = true
  #      }
  #    }
  #  }
  #}
  #depends_on = [aws_iam_role.replication]
}

resource "aws_s3_bucket_policy" "ssl_policy" {
  bucket = aws_s3_bucket.source_bucket.id
  policy = "${data.template_file.bucket_policy.rendered}"
}


#resource "aws_iam_role" "replication" {
#  name = "cdd-iam-role-repl-${local.s3_bucket_name}"
#  #permissions_boundary    = "arn:aws:iam::${local.account_id}:policy/ServiceRoleBoundary"
#  assume_role_policy = <<POLICY
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "s3.amazonaws.com"
#      },
#      "Effect": "Allow",
#      "Sid": ""
#    }
#  ]
#}
#POLICY
#}

#resource "aws_iam_role_policy" "replication" {
#  name = "cdd-iam-role-policy-replication-${local.s3_bucket_name}"
#  role = aws_iam_role.replication.id
#
#  policy = <<POLICY
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "s3:GetReplicationConfiguration",
#        "s3:ListBucket"
#      ],
#      "Effect": "Allow",
#      "Resource": [
#        "${aws_s3_bucket.source_bucket.arn}"
#      ]
#    },
#    {
#      "Action": [
#        "s3:GetObjectVersion",
#        "s3:GetObjectVersionAcl"
#      ],
#      "Effect": "Allow",
#      "Resource": [
#        "${aws_s3_bucket.source_bucket.arn}/*"
#      ]
#    },
#    {
#      "Action": [
#        "s3:ReplicateObject",
#        "s3:ReplicateDelete"
#      ],
#      "Effect": "Allow",
#      "Resource": "${aws_s3_bucket.replica_bucket.arn}/*"
#    }
#  ]
#}
#POLICY
#}


resource "aws_s3_bucket_public_access_block" "source_bucket" {
  bucket = aws_s3_bucket.source_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
#  provider = "aws.primary"

}


resource "aws_kms_key" "source_bucket" {
#  provider = "aws.primary"
  policy = "${data.template_file.kms_policy.rendered}"
  description             = "KMS key for S3"
  deletion_window_in_days = 10
  enable_key_rotation = true
}



#resource "aws_s3_bucket" "replica_bucket" {
#  bucket = "${local.s3_bucket_name}-crr"
#  acl    = "private"
#  provider = "aws.secondary"
#  versioning {
#    enabled = true
#  }
#  server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        kms_master_key_id = aws_kms_key.replica_bucket.arn
#        sse_algorithm     = "aws:kms"
#      }
#    }
#  }
#}

#resource "aws_s3_bucket_public_access_block" "replica_bucket" {
#  bucket = aws_s3_bucket.replica_bucket.id
#
#  block_public_acls       = true
#  block_public_policy     = true
#  ignore_public_acls      = true
#  restrict_public_buckets = true
#  provider = "aws.secondary"
#
#}


#resource "aws_kms_key" "replica_bucket" {
#  provider = "aws.secondary"
#
#  description             = "KMS key for S3"
#  deletion_window_in_days = 10
#}



#resource "aws_s3_bucket_acl" "this" {
#  bucket = aws_s3_bucket.this.id
#  acl    = "private"
#}

#resource "aws_s3_bucket_versioning" "this" {
#  bucket = aws_s3_bucket.this.id
#  versioning_configuration {
#    status = "Enabled"
#  }
#}

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id       = local.vpc_id
#   service_name = data.aws_vpc_endpoint_service.s3.service_name
# }

# resource "aws_vpc_endpoint_route_table_association" "private_s3" {
#   count           = length(local.route_tables_ids)
#   vpc_endpoint_id = aws_vpc_endpoint.s3.id
#   route_table_id  = local.route_tables_ids[count.index]
# }
