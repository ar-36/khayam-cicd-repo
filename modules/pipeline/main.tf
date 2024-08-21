
module "role" {
  source = "./modules/role"
  resource_prefix = var.environment
  common_tags = var.tags
}

module "codepipeline_kms" {
  source                = "./modules/kms"
  pipeline_role_arn = module.role.codepipeline_role_arn
  account_id = var.account_id
  common_tags = var.tags
  
  depends_on = [
    module.role
  ]
}

module "artifacts_bucket" {
  source = "./modules/s3"
  resource_prefix = var.environment
  common_tags = var.tags
}


module "policies" {
  source = "./modules/policy"
  resource_prefix = var.environment
  aws_region = var.region
  account_id = var.account_id
  repository_name = var.source_repo.name
  pipeline_name = var.pipeline_name
  cloud_watch_event_role_name = module.role.cloud_watch_event_role_name
  codepipeline_role_name = module.role.codepipeline_role_name
  kms_key_arn = module.codepipeline_kms.arn
  artifacts_bucket_name = module.artifacts_bucket.name
  common_tags = var.tags

  depends_on = [
    module.codepipeline_kms,
    module.artifacts_bucket
  ]
}


module "serviceCodeBuild" {
  source = "./modules/code-build"
  codebuild_name = var.codebuild_name
  role_arn = module.role.codepipeline_role_arn
  aws_region = var.region
  repo = var.source_repo
  env_vars = var.codebuild_env_vars

  vpc_config = var.codebuild_vpc_config
  kms_key_arn = module.codepipeline_kms.arn
  common_tags = var.tags

  depends_on = [
    module.codepipeline_kms
  ]
}


module "codepipeline" {
  source = "./modules/code-pipeline"
  pipeline_name = var.pipeline_name
  role_arn = module.role.codepipeline_role_arn
  artifacts_bucket_name = module.artifacts_bucket.name
  source_stage = {
    name = "Source",
    action = {
      run_order = 1,
      name = var.codecommit_stage_action_name,
      category = "Source",
      provider = "CodeCommit",
      namespace = "SourceVariables",
      output_artifacts = "SourceOutput",
      repo = var.source_repo
    }
  }
  build_stage = {
    name = "Build",
    action = {
      run_order = 2,
      name = var.codebuild_stage_action_name,
      category = "Build",
      provider = "CodeBuild",
      namespace = "BuildVariables",
      input_artifacts = "SourceOutput",
      output_artifacts = "BuildOutput",
      project_name = var.codebuild_name
    }
  }

  kms_key_arn = module.codepipeline_kms.arn
  common_tags = var.tags

  depends_on = [
    module.serviceCodeBuild,
    module.artifacts_bucket,
    module.codepipeline_kms
  ]
  
}


module "cloudwatch_event" {
  source = "./modules/cloudwatch-event"
  rule_name = var.cloudwatch_event_rule_name
  aws_region = var.region
  account_id = var.account_id
  cloud_watch_event_role_arn = module.role.cloud_watch_event_role_arn
  repo = var.source_repo
  pipeline_name = var.pipeline_name
  common_tags = var.tags

  depends_on = [
    module.role
  ]
}