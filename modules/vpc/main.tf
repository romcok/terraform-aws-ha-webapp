# Naming convention and tagging
module label {
  source      = "../label"
  name        = var.name
  namespace   = var.namespace
  environment = var.environment
  module      = "vpc"
  group       = var.group
}

# VPC
resource aws_vpc main {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = module.label.tags
}

# Internet gateway
resource aws_internet_gateway igw {
  vpc_id = aws_vpc.main.id
  tags   = module.label.tags
}

# Elastic IP for NAT
resource aws_eip nat {
  count = length(var.public_subnet_cidrs)

  vpc = true
  tags = merge(module.label.tags, {
    Name = "${module.label.id}-eip-${substr(var.availability_zones[count.index], length(var.availability_zones[count.index]) - 1, 1)}"
    Zone = var.availability_zones[count.index]
  })

  depends_on = [aws_internet_gateway.igw]
}

# NAT for public subnet
resource aws_nat_gateway nat {
  count = length(var.public_subnet_cidrs)

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = merge(module.label.tags, {
    Name = "${module.label.id}-nat-${substr(var.availability_zones[count.index], length(var.availability_zones[count.index]) - 1, 1)}"
    Zone = var.availability_zones[count.index]
  })

  depends_on = [aws_internet_gateway.igw]
}
