resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = var.tags
}

resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.availability_zones[0]

  tags = var.tags
}

resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.availability_zones[1]

  tags = var.tags
}

resource "aws_subnet" "private_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.availability_zones[2]

  tags = var.tags
}

resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.32.0/28"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = var.tags
}

resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.32.16/28"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = var.tags
}

resource "aws_subnet" "public_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.33.0/28"
  availability_zone = "us-east-1e"
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
  subnet_id     = aws_subnet.public_1.id
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
  count = 2

  subnet_id      = [
    aws_subnet.public_1,
    aws_subnet.public_2,
    aws_subnet.public_3
  ][count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = [
    aws_subnet.private_1,
    aws_subnet.private_2,
    aws_subnet.private_3
  ][count.index].id
  route_table_id = aws_route_table.private.id
}
