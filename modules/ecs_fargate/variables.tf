#terraform/modules/ecs_fargate/variables.tf
variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}

variable "web_image_url" {
  description = "The URL of the web container ECR repository"
  type        = string
}

variable "api_image_url" {
  description = "The URL of the API container ECR repository"
  type        = string
}

variable "web_environment" {
  description = "Environment variables for the web container"
  type        = list(object({
    name  = string
    value = string
  }))
}

variable "api_environment" {
  description = "Environment variables for the web container"
  type        = list(object({
    name  = string
    value = string
  }))
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(any)
  default     = {}
}

variable "desired_count" {
  description = "Desired number of tasks for the ECS service"
  type        = number
  default     = 1
}
