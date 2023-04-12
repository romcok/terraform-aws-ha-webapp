# Public subnets
resource aws_subnet public {
  count                   = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false # We don't need to map EIP
  
  tags                    = merge(module.label.tags, {
    Name = "${module.label.id}-public-subnet-${substr(var.availability_zones[count.index], length(var.availability_zones[count.index]) - 1, 1)}"
    Zone = var.availability_zones[count.index]
  })
}

# Private subnets
resource aws_subnet private {  
  count                   = length(var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags                    = merge(module.label.tags, {
    Name = "${module.label.id}-private-subnet-${substr(var.availability_zones[count.index], length(var.availability_zones[count.index]) - 1, 1)}"
    Zone = var.availability_zones[count.index]
  })
}
