resource "aws_vpc" "main" {
  cidr_block = var.cidr

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = var.tags
}

locals {
  // Each entry has a collection of ranges per availability zone
  az_subnet_ranges = [
    for cr in cidrsubnets(var.cidr, 2, 2, 2)
    : cidrsubnets(cr, 4, 4)
  ]

  public_subnet_ranges = [
    for cr in local.az_subnet_ranges
    : cr[0]
  ]

  private_subnet_ranges = [
    for cr in local.az_subnet_ranges
    : cr[1]
  ]
}

resource "aws_subnet" "private" {
  count = 3

  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_subnet_ranges[count.index]

  availability_zone = var.availability_zones[count.index]

  tags = var.tags
}

resource "aws_subnet" "public" {
  count = 3

  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_subnet_ranges[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = var.tags
}

resource "aws_eip" "ip" {
  count = var.up ? 1 : 0
  vpc = true
  tags = var.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = var.tags
}

resource "aws_nat_gateway" "nat" {
  count = var.up ? 1 : 0
  allocation_id = aws_eip.ip[0].id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = var.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count = 3

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = 3

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
