resource aws_ecs_task_definition webapp {
  family                   = "${module.label.id}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.task_cpu
  memory = var.task_memory

  execution_role_arn = aws_iam_role.task_execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name = "${module.label.id}-container"
      image     = var.container_image
      essential = true

      memoryReservation = var.task_memory

      networkMode = "awsvpc"
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.container_port
          hostPort      = var.host_port
        }
      ]

      environment = var.container_environment
      secrets     = var.container_secrets

      mountPoints = [
        for mount_point in var.container_mount_points: {
          sourceVolume  = mount_point.name
          containerPath = mount_point.path
          # readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.fargate_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  dynamic "volume" {
    for_each = var.volumes
    content {
      name      = volume.value.name
      # host_path = lookup(volume.value, "host_path", null)

      efs_volume_configuration {
        file_system_id          = lookup(volume.value, "file_system_id", null)
        root_directory          = lookup(volume.value, "root_directory", null)
        transit_encryption      = "ENABLED"
        transit_encryption_port = 2049

        authorization_config {
          access_point_id = lookup(volume.value, "access_point_id", null)
        }
      }
    }
  }

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-task"
  })
}

resource aws_vpc_security_group_ingress_rule volumes {
  count = length(var.volumes)

  security_group_id = lookup(element(var.volumes, count.index), "security_group_id")

  description                  = "${lookup(element(var.volumes, count.index), "name")} to ${module.label.name}"
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.use_security_group_id

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-${module.label.name}-to-${lookup(element(var.volumes, count.index), "name")}-ingress"
  })
}