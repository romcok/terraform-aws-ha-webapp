module fargate_security_group {
  source      = "./modules/security-group"
  name        = "fargate"
  group       = "compute"
  namespace   = var.name
  environment = var.environment

  vpc_id      = module.vpc.vpc_id
  description = "Security group for compute layer"

  ingress = concat([{
    name              = "alb-to-fargate"
    description       = "ALB to Fargate Rule"
    from_port         = var.container.port
    to_port           = var.container.port
    security_group_id = module.alb_security_group.id
    protocol          = "tcp"
    cidr_block        = null
  }], [
    for vpn_security_group_id in module.vpn_security_group.*.id : {
      name              = "vpn-to-fargate"
      description       = "VPN to Fargate Rule"
      from_port         = 0
      to_port           = 0
      security_group_id = vpn_security_group_id
      protocol          = "tcp"
      cidr_block        = null
    }
  ])

  egress_all = true
}


locals {
  container_environment = [
    for env_var_name, env_var_value in var.container.env_vars : {
      name = env_var_name
      value = coalesce(join("", values({ for k, v in {
              __ALB_URL__ = module.alb.url
              __DB_NAME__ = module.aurora.database_name
              __DB_USERNAME__ = module.aurora.database_username
              __DB_PASSWORD__ = module.aurora.database_password
              __DB_CLUSTER_ENDPOINT__ = module.aurora.cluster_endpoint
              __DB_MASTER_ENDPOINT__ = module.aurora.master_endpoint
              __DB_READER_ENDPOINT__ = module.aurora.reader_endpoint
              __DB_REPLICAS_ENDPOINT__ = join(",", module.aurora.read_replica_endpoints)
              __DB_ENDPOINTS__ = join(",", module.aurora.endpoints)
            } : k => v if env_var_value == k })), env_var_value)
    }
  ]
  container_secrets = [
    for secret_name, secret_arn in var.container.secrets : {
      name  = secret_name
      valueFrom = secret_arn
    }
  ]
}

module fargate {
  source      = "./modules/fargate"
  name        = "fargate"
  group       = "compute"
  namespace   = var.name
  environment = var.environment

  region                = var.region
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  use_security_group_id = module.fargate_security_group.id
  availability_zones    = module.vpc.availability_zones
  target_group_arn      = module.alb.target_group_arn

  task_cpu      = var.container.cpu
  task_memory   = var.container.memory
  task_stament  = null
  desired_count = var.container.count

  host_port               = var.container.port
  container_port          = var.container.port
  container_image         = var.container.image
  container_mount_points = [
    for mount_path in var.container.mount_paths: {
      name = "efs-volume"
      path = mount_path
    }
  ]
  container_environment  = local.container_environment
  container_secrets      = local.container_secrets
  

  volumes = [
    {
      name              = "efs-volume"
      security_group_id = module.efs_security_group.id
      file_system_id    = module.efs.volume_id
      root_directory    = var.container.volume_root
      access_point_id   = module.efs.access_point_id
    }
  ]
}
