resource "aws_route_table" "public-gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.common_tags, { Name = "public-gateway" })
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public-gateway.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}



/* Routing table for public subnet */
resource "aws_route_table" "public" {
  count = var.public_subnet_count
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.common_tags, { Name = "public-route-table-${count.index}" })
}
/* Routing table for private subnet */
resource "aws_route_table" "private" {
  count = var.private_subnet_count
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.common_tags, { Name = "private-route-table-${count.index}" })
}
resource "aws_route" "nat_gateway" {
  count = var.private_subnet_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  count = var.public_subnet_count
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public-gateway.id
}

resource "aws_route_table_association" "private" {
  count = var.private_subnet_count
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}