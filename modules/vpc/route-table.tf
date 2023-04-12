# Route table for public subnet
resource aws_route_table public {
  vpc_id = aws_vpc.main.id

  tags   = merge(module.label.tags, {
    Name = "${module.label.id}-public-route-table"
  })
}

# Route table for private subnet
resource aws_route_table private {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  tags  = merge(module.label.tags, {
    Name = "${module.label.id}-private-route-table-${substr(var.availability_zones[count.index], length(var.availability_zones[count.index]) - 1, 1)}"
    Zone = var.availability_zones[count.index]
  })
}

# Route to public internet gateway
resource aws_route public-igw {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Route to public NAT
resource aws_route public-nat {
  count = length(var.public_subnet_cidrs)

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}

# Route table associations
resource aws_route_table_association public {
  count          = length(var.public_subnet_cidrs)

  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

resource aws_route_table_association private {
  count          = length(var.private_subnet_cidrs)

  route_table_id = element(aws_route_table.private.*.id, count.index)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}
