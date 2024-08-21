variable "pipeline_name" {}
variable "role_arn" {}
variable "artifacts_bucket_name" {}
variable "source_stage" {}
variable "build_stage" {}
variable "kms_key_arn" {
  default = null
}
variable "common_tags" {}