locals {
  resource_prefix = "${lower(var.env)}-trends"
  account_id = data.aws_caller_identity.current.account_id
  repo = {
    name = "test-repo",
    branch = "master"
  }
  pipeline_name = "${local.resource_prefix}-ServiceCodePipeline"
  codebuild_name = "${local.resource_prefix}-ServiceCodeBuild"
}


module "role" {
  source = "./modules/role"
  resource_prefix = local.resource_prefix
  common_tags = local.common_tags
}

module "codepipeline_kms" {
  source                = "./modules/kms"
  pipeline_role_arn = module.role.codepipeline_role_arn
  account_id = local.account_id
  common_tags = local.common_tags
  
  depends_on = [
    module.role
  ]
}

module "artifacts_bucket" {
  source = "./modules/s3"
  resource_prefix = local.resource_prefix
  common_tags = local.common_tags
}


module "policies" {
  source = "./modules/policy"
  resource_prefix = local.resource_prefix
  aws_region = var.region
  account_id = local.account_id
  repository_name = local.repo.name
  pipeline_name = local.pipeline_name
  cloud_watch_event_role_name = module.role.cloud_watch_event_role_name
  codepipeline_role_name = module.role.codepipeline_role_name
  kms_key_arn = module.codepipeline_kms.arn
  artifacts_bucket_name = module.artifacts_bucket.name
  common_tags = local.common_tags

  depends_on = [
    module.codepipeline_kms,
    module.artifacts_bucket
  ]
}


module "serviceCodeBuild" {
  source = "./modules/code-build"
  codebuild_name = local.codebuild_name
  role_arn = module.role.codepipeline_role_arn
  aws_region = var.region
  repo = local.repo
  env_vars = {
    ENVIRONMENT = "dev",
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

  vpc_config = {
    id = "<vpc id>",
    subnets = ["<subnet id>"],
    security_groups = ["<security group id>"]
  }
  kms_key_arn = module.codepipeline_kms.arn
  common_tags = local.common_tags

  depends_on = [
    module.codepipeline_kms
  ]
}


module "codepipeline" {
  source = "./modules/code-pipeline"
  pipeline_name = local.pipeline_name
  role_arn = module.role.codepipeline_role_arn
  artifacts_bucket_name = module.artifacts_bucket.name
  source_stage = {
    name = "Source",
    action = {
      run_order = 1,
      name = "ServiceCodeCommit",
      category = "Source",
      provider = "CodeCommit",
      namespace = "SourceVariables",
      output_artifacts = "SourceOutput",
      repo = local.repo
    }
  }
  build_stage = {
    name = "Build",
    action = {
      run_order = 2,
      name = "ServiceCodeBuild",
      category = "Build",
      provider = "CodeBuild",
      namespace = "BuildVariables",
      input_artifacts = "SourceOutput",
      output_artifacts = "BuildOutput",
      project_name = local.codebuild_name
    }
  }

  kms_key_arn = module.codepipeline_kms.arn
  common_tags = local.common_tags

  depends_on = [
    module.serviceCodeBuild,
    module.artifacts_bucket,
    module.codepipeline_kms
  ]
  
}


module "cloudwatch_event" {
  source = "./modules/cloudwatch-event"
  rule_name = "${local.resource_prefix}-backend-pipeline-rule"
  aws_region = var.region
  account_id = local.account_id
  cloud_watch_event_role_arn = module.role.cloud_watch_event_role_arn
  repo = local.repo
  pipeline_name = local.pipeline_name
  common_tags = local.common_tags

  depends_on = [
    module.role
  ]
}