output vpc_id {
  value = aws_vpc.main.id
}

output vpc_arn {
  value = aws_vpc.main.arn
}

output public_subnet_ids {
  value = aws_subnet.public.*.id
}

output public_subnet_cidrs {
  value = aws_subnet.public.*.cidr_block
}

output private_subnet_ids {
  value = aws_subnet.private.*.id
}

output private_subnet_cidrs {
  value = aws_subnet.private.*.cidr_block
}

output igw_id {
  value = aws_internet_gateway.igw.id
}

output nat_ids {
  value = aws_nat_gateway.nat.*.id
}

output availability_zones {
  value = var.availability_zones
}

output dns_server {
  value = local.dns_server
}