module label {
  source      = "../label"
  name        = var.name
  namespace   = var.namespace
  environment = var.environment
  module      = "efs"
  group       = var.group
}

resource aws_efs_file_system volume {
  creation_token  = "${module.label.id}-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "elastic"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-efs"
  })
}

resource aws_efs_mount_target mount {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.volume.id
  subnet_id       = element(var.subnet_ids, count.index)
  security_groups = [var.use_security_group_id]
}

resource aws_efs_access_point volume {
  file_system_id = aws_efs_file_system.volume.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
    path = var.root_path
  }

  tags = module.label.tags
}