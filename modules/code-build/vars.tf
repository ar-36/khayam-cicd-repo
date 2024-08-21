variable "role_arn" {}
variable "aws_region" {}
variable "repo" {}
variable "codebuild_name" {}
variable "env_vars" {}
variable "kms_key_arn" {
  default = null
}
variable "vpc_config" {
  default = null
}
variable "common_tags" {}