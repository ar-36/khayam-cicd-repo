resource "aws_cloudwatch_event_rule" "pipeline" {
  name        = var.rule_name
  event_pattern = <<PATTERN
  {
    "source": [
      "aws.codecommit"
    ],
    "detail-type": [
      "CodeCommit Repository State Change"
    ],
    "resources": [
      "arn:aws:codecommit:${var.aws_region}:${var.account_id}:${var.repo.name}"
    ],
    "detail": {
      "event": [
        "referenceCreated",
        "referenceUpdated"
      ],
      "referenceType": [
        "branch"
      ],
      "referenceName":[
        "${var.repo.branch}"
      ]
    }
  }
  PATTERN

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "pipeline" {
  rule      = aws_cloudwatch_event_rule.pipeline.name
  arn       = "arn:aws:codepipeline:${var.aws_region}:${var.account_id}:${var.pipeline_name}"
  role_arn = var.cloud_watch_event_role_arn
}