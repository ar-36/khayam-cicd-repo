#terraform/modules/ecs_fargate/main.tf
module "global_constants" {
  source = "../global_constants"
}

# Security Group for ECS tasks
resource "aws_security_group" "ecs" {
  name        = "${var.cluster_name}-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  # ingress {
  #   from_port       = 3000
  #   to_port         = 3000
  #   protocol        = "tcp"
  #   security_groups = ["sg-00ebf614c8b31d9ec"]  # Update with Load Balancer SG ID if needed
  # }

  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.163.4.0/24", "172.25.8.10/32", "10.163.0.54/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.cluster_name}-ecs-sg" })
}

# CloudWatch Log Groups for ECS tasks
resource "aws_cloudwatch_log_group" "web" {
  name              = "TrendsNonprodWeb"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/TrendsNonprodApi"
  retention_in_days = 30
  tags              = var.tags
}

# IAM Role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name   = "${var.cluster_name}-ecs-task-execution-policy"
  role   = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM Role for ECS tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.cluster_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

# ECS Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = var.cluster_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "4096"
  cpu                      = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "TRENDS-dev-container"
      image = var.web_image_url
      essential = true
      memoryReservation = 512
      memory = 4096
      cpu = 256
      portMappings = [
        {
          name          = "trends-dev-container-3000-tcp"
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = var.web_environment
      secrets = [
        {
          name      = "SPRING_LDAP_PASSWORD"
          valueFrom = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/nep/spring.ldap.password"
        },
        {
          name      = "TRENDS_DATASOURCE_PASSWORD"
          valueFrom = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/nep/trends/dev/trends.datasource.password"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.web.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "TRENDSdev"
        }
      }
      volumesFrom = [
        {
          sourceContainer = "aqua-sidecar"
        }
      ]
    },
    {
      name  = "aqua-sidecar"
      image = var.api_image_url
      essential = false
      memoryReservation = 512
      memory = 4096
      cpu = 256
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "this" {
  name            = var.cluster_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs.id]
  }
}