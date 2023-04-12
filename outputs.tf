output alb_dns_name {
  value = module.alb.dns_name
}

output database_cluster_endpoint {
  value = module.aurora.cluster_endpoint
}

output database_cluster_reader_endpoint {
  value = module.aurora.reader_endpoint
}

output database_endpoints {
  value = module.aurora.endpoints
}

output database_master_endpoint {
  value = module.aurora.master_endpoint
}

output database_read_replica_endpoints {
  value = module.aurora.read_replica_endpoints
}

output database_username {
  value = module.aurora.database_username
}

/*output database_password {
  value = module.aurora.database_password
}*/

output database_name {
  value = module.aurora.database_name
}

output volume_dns_name {
  value = module.efs.volume_dns_name
}

output volume_access_point_id {
  value = module.efs.access_point_id
}

output vpn_id {
  value = one(module.vpn.*.id)
}

output vpn_arn {
  value = one(module.vpn.*.arn)
}

output vpn_dns_name {
  value = one(module.vpn.*.dns_name)
}