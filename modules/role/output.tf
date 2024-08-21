output "cloud_watch_event_role_arn" {
  value = aws_iam_role.cloud_watch_event_role.arn
}
output "cloud_watch_event_role_name" {
  value = aws_iam_role.cloud_watch_event_role.name
}


output "codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}
output "codepipeline_role_name" {
  value = aws_iam_role.codepipeline_role.name
}