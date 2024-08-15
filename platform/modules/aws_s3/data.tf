# ----
# DATA
# ----

# data "aws_vpc_endpoint_service" "s3" {
#   service      = "s3"
#   service_type = "Gateway"
# }

data "template_file" "kms_policy" {
  template = "${file("${path.module}/kms_policy.json.tpl")}"

  vars = {
    account_id = "${local.account_id}"
  }
}

data "template_file" "bucket_policy" {
  template = "${file("${path.module}/s3_bucket_policy.json.tpl")}"

  vars = {
    bucket = "${local.s3_bucket_name}"
  }
}

