resource "aws_iam_policy" "cwe_pipeline_execution_policy" {
  name = "${var.resource_prefix}-cwe-pipeline-execution-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codepipeline:StartPipelineExecution"
        ],
        Resource = [
          "arn:aws:codepipeline:${var.aws_region}:${var.account_id}:${var.pipeline_name}"
        ]
      }
    ]
  })

  tags = var.common_tags
}
resource "aws_iam_role_policy_attachment" "cwe_pipeline_execution_policy_attachment" {
  role       = "${var.cloud_watch_event_role_name}"
  policy_arn = "${aws_iam_policy.cwe_pipeline_execution_policy.arn}"
}



resource "aws_iam_policy" "codepipeline_policy" {
  name = "${var.resource_prefix}-codepipeline-policy"
  description = "Policy to allow codepipeline to execute"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject*",
          "s3:GetBucket*",
          "s3:List*",
          "s3:DeleteObject*",
          "s3:PutObject*",
          "s3:Abort*"
        ],
        Resource = [
          "arn:aws:s3:::${var.artifacts_bucket_name}",
          "arn:aws:s3:::${var.artifacts_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterfacePermission"
        ],
        Resource = "arn:aws:ec2:${var.aws_region}:${var.account_id}:network-interface/*",
        Condition = {
          StringEquals = {
            "ec2:Subnet": [
              "arn:aws:ec2:${var.aws_region}:${var.account_id}:subnet/*"
            ],
            "ec2:AuthorizedService": "codebuild.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch",
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetProjects",
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        Resource = "arn:aws:codebuild:${var.aws_region}:${var.account_id}:*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Decrypt"
        ],
        Resource = var.kms_key_arn
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GitPull",
          "codecommit:GitPush",
          "codecommit:GetBranch",
          "codecommit:CreateCommit",
          "codecommit:ListRepositories",
          "codecommit:BatchGetCommits",
          "codecommit:BatchGetRepositories",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:ListBranches",
          "codecommit:UploadArchive"
        ],
        Resource = "arn:aws:codecommit:${var.aws_region}:${var.account_id}:${var.repository_name}"
      }
    ]
  })

  tags = var.common_tags
}
resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::${var.account_id}:policy/${aws_iam_policy.codepipeline_policy.name}",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    # "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess"
  ])
  role       = var.codepipeline_role_name
  policy_arn = each.value
}