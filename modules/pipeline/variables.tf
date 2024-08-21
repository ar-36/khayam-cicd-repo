#terraform/modules/pipeline/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
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

variable "source_repo" {
  description = "Name & branch of the Source Repository"
  type        = map(any)
  default     = {}
}

variable "pipeline_name" {
  description = "Name of the Code Pipeline"
  type        = string
}

variable "codebuild_name" {
  description = "Name of the Code Build"
  type        = string
}

variable "codecommit_stage_action_name" {
  description = "Action name for CodeCommit stage"
  type        = string
}

variable "codebuild_stage_action_name" {
  description = "Action name for Codebuild Build stage"
  type        = string
}

variable "codebuild_env_vars" {
  description = "Environment variables for codebuild"
  type        = map(any)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
  default     = []
}

variable "security_groups" {
  description = "The IDs of the security groups"
  type        = list(string)
  default     = []
}

variable "cloudwatch_event_rule_name" {
  description = "cloudwatch event rule name"
  type        = string
}