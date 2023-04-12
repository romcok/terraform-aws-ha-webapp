# Naming convention and tagging
module label {
  source      = "../label"
  name        = var.name
  namespace   = var.namespace
  environment = var.environment
  module      = "alb"
  group       = var.group
}

resource aws_alb main {
  name            = module.label.id
  load_balancer_type = "application"
  enable_cross_zone_load_balancing = true
  internal        = var.internal
  subnets         = var.subnet_ids
  security_groups = [ var.use_security_group_id ]

  tags = module.label.tags
}

resource aws_alb_target_group http {
  name        = "${module.label.id}-group"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    healthy_threshold   = 3
    interval            = 120
    protocol            = "HTTP"
    matcher             = 200
    timeout             = 3
    path                = var.health_check_path
    unhealthy_threshold = 2
  }
  stickiness {
    type = "lb_cookie"
  }

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-target-group"
  })
}

resource aws_alb_listener http {
  load_balancer_arn = aws_alb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.http.id
    type             = "forward"
  }

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-http-listener"
  })

  depends_on = [
    aws_alb_target_group.http
  ]
}