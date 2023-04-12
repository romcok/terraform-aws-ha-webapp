resource aws_cloudwatch_log_group connection_log {
  name = "${module.label.id}-group"

  tags = module.label.tags
}

resource aws_cloudwatch_log_stream connection_log {
  name           = "${module.label.id}-stream"
  log_group_name = aws_cloudwatch_log_group.connection_log.name
}

resource aws_ec2_client_vpn_network_association access {
  count = length(var.subnet_ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = element(var.subnet_ids, count.index)
  # security_group        = [var.use_security_group_id]
}

resource aws_ec2_client_vpn_authorization_rule access_rule {
  count = length(var.subnet_ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = element(var.subnet_cidrs, count.index)
  authorize_all_groups   = true

  timeouts {
    create = "20m"
  }
}
