module label {
  source      = "../label"
  name        = var.name
  namespace   = var.namespace
  environment = var.environment
  module      = "aurora"
  group       = var.group
}

resource aws_db_subnet_group cluster {
  name       = "${module.label.id}-cluster-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-subnet-group"
  })
}

resource aws_rds_cluster main {
  cluster_identifier      = "${module.label.id}-cluster"
  engine                  = "aurora-${var.engine}"
  engine_mode             = "provisioned"
  engine_version          = var.engine_version
  database_name           = local.database_name
  master_username         = var.database_username
  master_password         = var.database_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "02:00-03:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = var.skip_final_snapshot
  vpc_security_group_ids  = [var.use_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.cluster.name
  
  depends_on = [
    aws_db_subnet_group.cluster
  ]

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-cluster"
  })
}

resource aws_rds_cluster_instance master {
  identifier         = "${module.label.id}-master-${substr(local.master_availability_zone, length(local.master_availability_zone) - 1, 1)}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
  availability_zone  = local.master_availability_zone
  promotion_tier     = 1

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-master"
    Zone = local.master_availability_zone
  })

  depends_on = [
    aws_rds_cluster.main
  ]
}

resource aws_rds_cluster_instance read_replica {
  count = length(local.read_replica_availability_zones)

  identifier         = "${module.label.id}-read-replica-${substr(element(local.read_replica_availability_zones, count.index), length(element(local.read_replica_availability_zones, count.index)) - 1, 1)}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
  availability_zone  = element(local.read_replica_availability_zones, count.index)
  promotion_tier     = 2 + count.index

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-read-replica"
    Zone = element(local.read_replica_availability_zones, count.index)
  })

  depends_on = [
    aws_rds_cluster_instance.master
  ]
}
