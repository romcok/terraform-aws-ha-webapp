resource aws_iam_role task_execution_role {
  name               = "${module.label.id}-execution-role"
  path               = "/system/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = module.label.tags
}

resource aws_iam_role_policy execution_role_policy {
  name = "${module.label.id}-ssm-policy"
  role = aws_iam_role.task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession"
        ]
        Resource = "arn:aws:ssm:*:*:session/*"
      }
    ]
  })
}

resource aws_iam_policy ssm_policy {
  count = length(var.container_secrets) > 0 ? 1 : 0

  name        = "ssm-access-policy"
  description = "Policy to allow access to SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for ssm_arn in var.container_secrets: {
        Action   = "ssm:GetParameters"
        Effect   = "Allow"
        Resource = ssm_arn.valueFrom
      }
    ]
  })
}

resource aws_iam_role_policy_attachment ssm_policy_attachment {
  count = length(var.container_secrets) > 0 ? 1 : 0

  policy_arn = element(aws_iam_policy.ssm_policy.*.arn, count.index)
  role       = aws_iam_role.task_execution_role.name
}

resource aws_iam_role task_role {
  name  = "${module.label.id}-task-role"
  path  = "/system/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = module.label.tags
}

resource aws_iam_policy task_policy {
  count       = var.task_stament == null ? 0 : 1
  name        = "${module.label.id}-task-policy"
  path        = "/system/"
  description = "IAM policy for ${module.label.id} Fargate task"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      var.task_stament
    ]
  })

  tags = module.label.tags
}

resource aws_iam_role_policy_attachment task_attachment {
  count      = var.task_stament == null ? 0 : 1
  role       = element(aws_iam_role.task_role.*.name, count.index)
  policy_arn = element(aws_iam_policy.task_policy.*.arn, count.index)
}

resource aws_iam_policy logs_policy {
  name = "${module.label.id}-logs-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutLogEventsBatch"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.fargate_logs.arn}:*"
      }
    ]
  })

  tags = module.label.tags
}

resource aws_iam_role_policy_attachment logs_policy {
  policy_arn = aws_iam_policy.logs_policy.arn
  role       = aws_iam_role.task_execution_role.name
}
