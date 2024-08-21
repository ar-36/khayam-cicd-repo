resource "aws_codepipeline" "pipeline" {

  name     = var.pipeline_name
  role_arn = var.role_arn
  # pipeline_type = "V2"
  # execution_mode = "QUEUED"

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"

    dynamic "encryption_key" {
      for_each = (var.kms_key_arn != null) ? [1] : []

      content {
        id   = var.kms_key_arn
        type = "KMS"
      }
    }
  }

  stage {
    name = var.source_stage.name

    action {
      name             = var.source_stage.action.name
      category         = var.source_stage.action.category
      owner            = "AWS"
      version          = "1"
      provider         = var.source_stage.action.provider
      namespace        = var.source_stage.action.namespace
      output_artifacts = [var.source_stage.action.output_artifacts]
      run_order        = var.source_stage.action.run_order

      configuration = {
        RepositoryName = var.source_stage.action.repo.name
        BranchName       = var.source_stage.action.repo.branch
        PollForSourceChanges = "false"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }


  stage {
    name = var.build_stage.name

    action {
      name = var.build_stage.action.name
      category = var.build_stage.action.category
      owner = "AWS"
      version = "1"
      provider = var.build_stage.action.provider
      namespace = var.build_stage.action.namespace
      input_artifacts  = [var.build_stage.action.input_artifacts]
      output_artifacts = [var.build_stage.action.output_artifacts]

      configuration = {
        ProjectName = var.build_stage.action.project_name
      } 
    }
  }

  tags = var.common_tags

}