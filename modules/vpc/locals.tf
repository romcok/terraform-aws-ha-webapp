locals {
  vpc_cidr_base = cidrsubnet(var.cidr_block, 0, 0)
  dns_server    = cidrhost(local.vpc_cidr_base, 2)
}