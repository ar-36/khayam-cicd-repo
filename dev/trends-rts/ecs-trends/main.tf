# terraform/dev/trends-rts/ecs-trends/main.tf
provider "aws" {
  region = module.global_constants.region
}

module "global_constants" {
  source = "../../../modules/global_constants"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "kk-terraform-state-bucket"
    key    = "dev/trends-rts/vpc/terraform.tfstate"
    region = module.global_constants.region
  }
}

locals {
  cluster_name = "TrendsNonprodCodePipelineCdkStackv2TRENDSdevtaskdefE2393CD0"
  tags         = { env = "dev" }
}

module "ecs" {
  source             = "../../../modules/ecs_fargate"
  cluster_name       = local.cluster_name
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets
  web_image_url      = "123456789012.dkr.ecr.us-east-1.amazonaws.com/trends:dev"  
  api_image_url      = "123456789012.dkr.ecr.us-east-1.amazonaws.com/aqua-sidecar:latest"
  region             = module.global_constants.region
  tags               = local.tags
  web_environment    = [
    {
      name  = "AQUA_TOKEN"
      value = "123df3215-5d4f5d4f5-12d1fd-54d5f4d-54d5f4d"
    },
    {
      name  = "LD_PRELOAD"
      value = "/.aquasec/bin/$PLATFORM/slklib.so"
    },
    {
      name  = "AQUA_DEBUG_TYPE"
      value = "STDOUT"
    },
    {
      name  = "AQUA_IMAGE_ID"
      value = "sha256:ad4a940fd198f092b69203e443fc5719b6a699cbdf084c72be43cfe35d8e219d"
    },
    {
      name  = "AQUA_SERVER"
      value = "10.163.0.54:18443"
    },
    {
      name  = "AQUA_MICROENFORCER"
      value = "1"
    }
  ]
  api_environment    = []  # No environment variables for the sidecar container
  desired_count      = 2
}
