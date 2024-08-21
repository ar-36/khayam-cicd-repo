resource "aws_iam_role" "cloud_watch_event_role" {
  name = "${var.resource_prefix}-cloudwatch-event-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  })
  
  tags = var.common_tags
}


resource "aws_iam_role" "codepipeline_role" {
  name = "${var.resource_prefix}-codepipeline-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "codepipeline.amazonaws.com"
        },
        "Effect": "Allow"
      },
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "codebuild.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  })

  tags = var.common_tags
}