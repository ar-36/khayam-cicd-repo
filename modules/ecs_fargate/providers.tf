#terraform/modules/ecs_fargate/providers.tf
provider "aws" {
  region = var.region
}