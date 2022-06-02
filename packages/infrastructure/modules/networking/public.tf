resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_subnet_ranges[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    { Name = "${var.name}_public_${count.index}" }
  )
}

resource "aws_eip" "nat_ip" {
  count = var.up ? local.used_azs : 0

  vpc = true
  tags = var.tags
}

resource "aws_nat_gateway" "nat" {
  count = var.up ? local.used_azs : 0

  allocation_id = aws_eip.nat_ip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.igw]

  tags = var.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    { Name = "${var.name}_public" }
  )
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
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public.*.id
}

resource "aws_network_acl_rule" "ssh_ingress" {
  count = length(var.ssh_cidrs)

  network_acl_id = aws_network_acl.public.id

  egress      = false
  rule_number = 100 + count.index * 2
  rule_action = "allow"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_block  = var.ssh_cidrs[count.index]
}

resource "aws_network_acl_rule" "ssh_egress" {
  count = length(var.ssh_cidrs)

  network_acl_id = aws_network_acl.public.id

  egress      = true
  rule_number = 101 + count.index * 2
  rule_action = "allow"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_block  = var.ssh_cidrs[count.index]
}

resource "aws_network_acl_rule" "public_to_private_ingress" {
  count = length(local.private_subnet_ranges)

  network_acl_id = aws_network_acl.public.id

  egress      = false
  rule_number = 150 + count.index * 2
  rule_action = "allow"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_block  = local.private_subnet_ranges[count.index]
}

resource "aws_network_acl_rule" "public_to_private_egress" {
  count = length(local.private_subnet_ranges)

  network_acl_id = aws_network_acl.public.id

  egress      = true
  rule_number = 151 + count.index * 2
  rule_action = "allow"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_block  = local.private_subnet_ranges[count.index]
}

resource "aws_network_acl_rule" "outbound_http" {
  network_acl_id = aws_network_acl.public.id

  egress      = true
  rule_number = 225
  rule_action = "allow"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_block  = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "outbound_https" {
  network_acl_id = aws_network_acl.public.id

  egress      = true
  rule_number = 226
  rule_action = "allow"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_block  = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "outbound_ingress" {
  network_acl_id = aws_network_acl.public.id

  egress      = false
  rule_number = 200
  rule_action = "allow"
  from_port   = 1024
  to_port     = 65535
  protocol    = "tcp"
  cidr_block  = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "outbound_egress" {
  network_acl_id = aws_network_acl.public.id

  egress      = true
  rule_number = 201
  rule_action = "allow"
  from_port   = 1024
  to_port     = 65535
  protocol    = "tcp"
  cidr_block  = "0.0.0.0/0"
}
