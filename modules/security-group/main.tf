# Naming convention and tagging
module label {
  source      = "../label"
  name        = var.name
  namespace   = var.namespace
  environment = var.environment
  module      = "security-group"
  group       = var.group
}

resource aws_security_group main {
  name        = "${module.label.id}-sg"
  description = var.description

  vpc_id = var.vpc_id

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-sg"
  })

  lifecycle {
    create_before_destroy = false
  }

  timeouts {
    create = var.security_group_create_timeout
    delete = var.security_group_delete_timeout
  }
}

resource aws_vpc_security_group_ingress_rule ingress {
  count = length(var.ingress)

  security_group_id            = aws_security_group.main.id
  cidr_ipv4                    = lookup(element(var.ingress, count.index), "cidr_block")
  description                  = lookup(element(var.ingress, count.index), "description")
  from_port                    = lookup(element(var.ingress, count.index), "from_port")
  to_port                      = lookup(element(var.ingress, count.index), "to_port")
  ip_protocol                  = lookup(element(var.ingress, count.index), "protocol", "tcp")
  referenced_security_group_id = var.ingress[count.index].security_group_id # lookup(element(var.egress, count.index), "security_group_id")

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-${lookup(element(var.ingress, count.index), "name")}-ingress"
  })
}

resource aws_vpc_security_group_ingress_rule ingress_all {
  count = var.ingress_all ? 1 : 0

  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Ingress all traffic to security group"
  ip_protocol       = -1

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-all-egress"
  })
}

resource aws_vpc_security_group_egress_rule egress {
  count = length(var.egress)

  security_group_id            = aws_security_group.main.id
  cidr_ipv4                    = lookup(element(var.egress, count.index), "cidr_block")
  description                  = lookup(element(var.egress, count.index), "description")
  from_port                    = lookup(element(var.egress, count.index), "from_port")
  to_port                      = lookup(element(var.egress, count.index), "to_port")
  ip_protocol                  = lookup(element(var.egress, count.index), "protocol", "tcp")
  referenced_security_group_id = lookup(element(var.egress, count.index), "security_group_id")

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-${lookup(element(var.egress, count.index), "name")}-egress"
  })
}

resource aws_vpc_security_group_egress_rule egress_all {
  count = var.egress_all ? 1 : 0

  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Egress all traffic from security group"
  ip_protocol       = -1

  tags = merge(module.label.tags, {
    Name = "${module.label.id}-all-egress"
  })
}