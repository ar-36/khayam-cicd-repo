resource "aws_codebuild_project" "build" {

  name           = var.codebuild_name
  service_role   = var.role_arn
  encryption_key = var.kms_key_arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  
  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"


    dynamic "environment_variable" {
      for_each = var.env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }
  
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
  
  source {
    type      = "CODECOMMIT"
    location = "https://git-codecommit.${var.aws_region}.amazonaws.com/v1/repos/${var.repo.name}"
    buildspec = "buildspec.yml"
    git_clone_depth = 1
  }

  dynamic "vpc_config" {
    for_each = (var.vpc_config != null) ? [1] : []
    content {
      vpc_id              = var.vpc_config.id
      subnets             = var.vpc_config.subnets
      security_group_ids  = var.vpc_config.security_groups
    }
  }

  source_version = "refs/heads/${var.repo.branch}"

  tags = var.common_tags
}