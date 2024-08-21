# terraform/dev/trends-rts/ecs-trends/backend.tf
terraform {
  backend "s3" {
    bucket         = "kk-terraform-state-bucket"
    key            = "dev/trends-rts/ecs-trends/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kk-terraform-lock-table"
    encrypt        = true
  }
}