# Naming convention and tagging
module label {
  source      = "../label"
  name        = var.name
  namespace   = var.namespace
  environment = var.environment
  module      = "fargate"
  group       = var.group
}

resource aws_ecs_cluster main {
  name = "${module.label.id}-cluster"

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-cluster",
  })
}

resource aws_ecs_service webapp {
  name                   = "${module.label.id}-service"
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.webapp.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE" 
  enable_execute_command = true

  network_configuration {
    security_groups  = [var.use_security_group_id]
    subnets          = var.subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${module.label.id}-container"
    container_port   = var.container_port
  }
  /*
  lifecycle {
    ignore_changes = [/*task_definition, desired_count]
  }*/

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-service",
  })

  depends_on = [
    aws_ecs_task_definition.webapp
  ]
}
