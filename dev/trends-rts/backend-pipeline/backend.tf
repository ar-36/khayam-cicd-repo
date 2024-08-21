# terraform/dev/trends-rts/backend-pipeline/backend.tf
terraform {
  backend "s3" {
    bucket         = "kk-terraform-state-bucket"
    key            = "dev/trends-rts/backend-pipeline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kk-terraform-lock-table"
    encrypt        = true
  }
}