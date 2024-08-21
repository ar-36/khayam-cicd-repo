#terraform/dev/backend-pipeline/vpc/main.tf
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
  env          = "dev"
  vpc_id       = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids   = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
}



resource "aws_security_group" "pipeline" {
  name        = "${local.env}-ServiceCodePipeline-securitygroup"
  vpc_id      = local.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


module "backend_pipeline" {
  source                        = "../../../modules/pipeline"
  region                        = module.global_constants.region
  environment                   = local.env
  account_id                    = ""
  tags                          = { 
    environment = "${lower(local.env)}" 
    project = "AWS CI/CD Pipeline"
    managedby = "TRENDS"
  }
  source_repo                   = {
    name = "test-repo",
    branch = "master"
  }
  pipeline_name                 = "${local.env}-ServiceCodePipeline"
  codebuild_name                = "${local.env}-ServiceCodeBuild"
  codecommit_stage_action_name  = "ServiceCodeCommit"
  codebuild_stage_action_name   = "ServiceCodeBuild"
  codebuild_env_vars            = {
    ENVIRONMENT = local.env,
    IMAGE_TAG = "dev",
    IMAGE_REPO_NAME = "trends",
    PROJECT_NAME = "TRENDS",
    VERSION = "1.0.0.3",
    DEPENDENCIES_BUCKET = "nep-npm-dev-use1-1234567890",
    CONTAINER_NAME = "TRENDS-dev-container",
    VERACODE_VID = "vera01fi-9bad8d8183043b530757d160e55797ce",
    VERACODE_VKEY = "vera01fs-e1d37c0efd5c051fa95c3ffbfc5cb5079b578907ee878c3e2c11484e6a81ae24deb272bbde260a7456539ffabb2ece35949fb4135a01a21a76c06b93382d8e2f",
    PROXY_HOST = "10.163.0.170",
    PROXY_PORT = "3128",
    VERACODE_APP_NAME = "TRENDS-Cloud-Services - DEV",
    VERACODE_APP_ID = "4307",
    ECS_TASK_FAMILY = "TrendsNonprodCodePipelineCdkStackv2TRENDSdevtaskdefE2393CD0",
    ECS_CLUSTER = "TRENDSdev",
    ECS_SERVICE_NAME = "TrendsNonprodCodePipelineCdkStackv2-serviceTRENDSdevService3ECB19E7-YNJtkpjwB9pw",
    VERACODE_APP_NAME_UI = "TRENDS-Cloud - DEV",
    VERACODE_APP_ID_UI = "4304"
  }

  # codebuild_vpc_config          = {
  #   id = local.vpc_id,
  #   subnets = local.subnet_ids,
  #   security_groups = [aws_security_group.pipeline.id]
  # }
  vpc_id                        = local.vpc_id
  subnet_ids                    = local.subnet_ids
  security_groups               = [aws_security_group.pipeline.id]

  cloudwatch_event_rule_name    = "${local.env}-ServiceCodePipelineRule"
}