output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = aws_ecs_cluster.prefect_cluster.arn
}

output "worker_service_id" {
  description = "ID (ARN) of the ECS Service"
  value       = aws_ecs_service.prefect_worker_service.id
}

output "worker_service_desired_count" {
  description = "Desired task count set for the ECS service"
  value       = aws_ecs_service.prefect_worker_service.desired_count
}