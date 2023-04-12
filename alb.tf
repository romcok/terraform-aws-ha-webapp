module alb_security_group {
  source      = "./modules/security-group"
  name        = "alb"
  group       = "network"
  namespace   = var.name
  environment = var.environment

  vpc_id      = module.vpc.vpc_id
  description = "Security group for application load balancer"

  ingress = [{
    name              = "http-alb"
    description       = "IGW to ALB Rule"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_block        = "0.0.0.0/0"
    security_group_id = null
  }]

  egress_all = true
}

module alb {
  source      = "./modules/alb"
  name        = "alb"
  group       = "network"
  namespace   = var.name
  environment = var.environment

  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnet_ids
  use_security_group_id = module.alb_security_group.id
  
  target_port       = var.container.port
  health_check_path = var.container.health_check_path
}
