#private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count = var.private_subnet_count
  cidr_block              = local.private_subnets_addresses[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, { Name = "private-subnet" })
}

