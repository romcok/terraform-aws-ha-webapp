resource aws_cloudwatch_log_group fargate_logs {
  name = "/ecs/${module.label.id}-${module.label.id}-container"

  tags = module.label.tags
}