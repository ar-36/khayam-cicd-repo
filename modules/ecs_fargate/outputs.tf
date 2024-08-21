#terraform/modules/ecs_fargate/outputs.tf
output "cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.this.id
}

output "task_definition_arn" {
  description = "ECS Task Definition ARN"
  value       = aws_ecs_task_definition.this.arn
}

output "service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.this.name
}
