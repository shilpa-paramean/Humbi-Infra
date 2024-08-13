terraform {
  backend "s3" {
    bucket  = "citadel-terraform-backend"
    key     = "platform"
    region  = "ap-southeast-2"
    encrypt = true
    # dynamodb_table = "terraform-lock"
    # role_arn = "arn:aws:iam::953027019050:role/InfraDeploy"
  }
}
