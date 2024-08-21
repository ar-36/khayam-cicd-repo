resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.resource_prefix}-pipeline-artifacts"

  tags = var.common_tags
}