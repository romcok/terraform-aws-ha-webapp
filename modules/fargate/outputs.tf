output cluster_name {
  value = aws_ecs_cluster.main.name
}

output service_name {
  value = aws_ecs_service.webapp.name
}

output container_name {
  value = local.container_name
}