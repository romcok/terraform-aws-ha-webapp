module efs_security_group {
  source      = "./modules/security-group"
  name        = "efs"
  group       = "storage"
  namespace   = var.name
  environment = var.environment

  vpc_id      = module.vpc.vpc_id
  description = "Security group for storage layer"

  ingress = [
    for vpn_security_group_id in module.vpn_security_group.*.id : {
      name              = "vpn-to-efs"
      description       = "VPN to EFS Rule"
      from_port         = 2049
      to_port           = 2049
      security_group_id = vpn_security_group_id
      protocol          = "tcp"
      cidr_block        = null
    }
  ]
}

module efs {
  source      = "./modules/efs"
  name        = "volume"
  group       = "storage"
  namespace   = var.name
  environment = var.environment

  subnet_ids            = module.vpc.private_subnet_ids
  use_security_group_id = module.efs_security_group.id

  root_path             = var.container.volume_root
}
