terraform {
  backend "s3" {
    bucket  = "citadel-terraform-backend"
    key     = "backup"
    region  = "ap-southeast-2"
    encrypt = true
  }
}
