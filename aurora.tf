module aurora_security_group {
  source      = "./modules/security-group"
  name        = "aurora"
  group       = "database"
  namespace   = var.name
  environment = var.environment

  vpc_id      = module.vpc.vpc_id
  description = "Security group for database layer"

  ingress = concat([{
    name              = "fargate-to-rds"
    description       = "Fargate to RDS Rule"
    from_port         = 3306
    to_port           = 3306
    security_group_id = module.fargate_security_group.id
    protocol          = "tcp"
    cidr_block        = null
  }], [
    for vpn_security_group_id in module.vpn_security_group.*.id : {
      name              = "vpn-to-rds"
      description       = "VPN to RDS Rule"
      from_port         = 3306
      to_port           = 3306
      security_group_id = vpn_security_group_id
      protocol          = "tcp"
      cidr_block        = null
    }
  ])

  egress_all = true
}

module aurora {
  source      = "./modules/aurora"
  name        = "aurora"
  group       = "database"
  namespace   = var.name
  environment = var.environment

  vpc_id                = module.vpc.vpc_id
  use_security_group_id = module.aurora_security_group.id
  subnet_ids            = module.vpc.private_subnet_ids
  availability_zones    = module.vpc.availability_zones

  engine_version          = var.database.version
  instance_class          = var.database.instance
  backup_retention_period = var.database.backup_retention_period
  skip_final_snapshot     = var.database.skip_final_snapshot

  database_username     = var.database.username
  database_password = var.database.password
}
