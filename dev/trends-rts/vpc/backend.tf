#terraform/dev/trends-rts/vpc/backend.tf
terraform {
  backend "s3" {
    bucket         = "kk-terraform-state-bucket"
    key            = "dev/trends-rts/vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kk-terraform-lock-table"
    encrypt        = true
  }
}