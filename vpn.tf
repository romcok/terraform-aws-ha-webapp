module vpn_security_group {
  count = var.vpn.enabled ? 1 : 0

  source      = "./modules/security-group"
  name        = "vpn"
  group       = "network"
  namespace   = var.name
  environment = var.environment

  vpc_id      = module.vpc.vpc_id
  description = "Security group for VPN client access"

  # ingress_all = true
  ingress = [{
    name              = "vpn-access"
    description       = "VPN access to VPC private subnets"
    from_port         = 443
    to_port           = 443
    protocol          = "udp"
    cidr_block        = var.vpn.cidr_block
    security_group_id = null
  }]

  egress_all = true
}

module vpn {
  count       = var.vpn.enabled ? 1 : 0
  source      = "./modules/vpn"
  name        = "vpn"
  group       = "network"
  namespace   = var.name
  environment = var.environment

  cidr_block            = var.vpn.cidr_block
  use_security_group_id = module.vpn_security_group.0.id
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  subnet_cidrs          = module.vpc.private_subnet_cidrs
  dns_servers           = [ module.vpc.dns_server ] 

  server_private_key = var.vpn.server_private_key
  server_certificate = var.vpn.server_certificate
  client_private_key = var.vpn.client_private_key
  client_certificate = var.vpn.client_certificate
  certificate_authority = var.vpn.certificate_authority
}
