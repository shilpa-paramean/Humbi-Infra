terraform {
  backend "s3" {
    bucket  = "bubbletea-terraform-backend"
    key     = "audit"
    region  = "ap-southeast-2"
    encrypt = true
    # dynamodb_table = "terraform-lock"
    role_arn = "arn:aws:iam::499834202973:role/InfraDeployAccess" # management role
  }
}
