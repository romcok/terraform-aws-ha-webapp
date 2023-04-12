output master_endpoint {
  value = aws_rds_cluster_instance.master.endpoint
}

output read_replica_endpoints {
  value = aws_rds_cluster_instance.read_replica.*.endpoint
}

output endpoints {
  value = concat([
    aws_rds_cluster_instance.master.endpoint
  ], aws_rds_cluster_instance.read_replica.*.endpoint)
}

output cluster_endpoint {
  value = aws_rds_cluster.main.endpoint
}

output reader_endpoint {
  value = aws_rds_cluster.main.reader_endpoint
}

output database_username {
  value = aws_rds_cluster.main.master_username
}

output database_password {
  value = aws_rds_cluster.main.master_password
}

output database_name {
  value = aws_rds_cluster.main.database_name
}