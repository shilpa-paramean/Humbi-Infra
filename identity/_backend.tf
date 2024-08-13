terraform {
  backend "s3" {
    bucket  = "citadel-terraform-backend"
    key     = "identity"
    region  = "ap-southeast-2"
    encrypt = true
    # dynamodb_table = "terraform-lock"
    # role_arn = "arn:aws:iam::816220623688:role/InfraDeployAccess" # shared-services role
  }
}
