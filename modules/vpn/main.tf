module label {
  source      = "../label"
  name        = var.name
  namespace   = var.namespace
  environment = var.environment
  module      = "vpn"
  group       = var.group
}

resource aws_ec2_client_vpn_endpoint main {
  description            = "Client VPN Access to ${join(", ", var.subnet_cidrs)}"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.cidr_block
  vpc_id                 = var.vpc_id 
  security_group_ids     = [ var.use_security_group_id ]
  split_tunnel           = true 
  dns_servers = var.dns_servers
  transport_protocol = "udp"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_root.arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.connection_log.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.connection_log.name
  }

  tags = module.label.tags
}
