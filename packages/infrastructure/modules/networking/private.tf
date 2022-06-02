resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_subnet_ranges[count.index]

  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    { Name = "${var.name}_private_${count.index}" }
  )
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    { Name = "${var.name}_private_${count.index}" }
  )
}

resource "aws_route" "nat_route" {
  count = length(aws_nat_gateway.nat)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_network_acl_rule" "private_public_ingress" {
  count = length(local.public_subnet_ranges)

  network_acl_id = aws_network_acl.private.id

  egress      = false
  rule_number = 100 + count.index * 2
  rule_action = "allow"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_block  = local.public_subnet_ranges[count.index]
}

resource "aws_network_acl_rule" "private_public_egress" {
  count = length(local.public_subnet_ranges)

  network_acl_id = aws_network_acl.private.id

  egress      = true
  rule_number = 101 + count.index * 2
  rule_action = "allow"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_block  = local.public_subnet_ranges[count.index]
}

resource "aws_network_acl_rule" "private_nat_gateway_https_egress" {
  network_acl_id = aws_network_acl.private.id

  egress      = true
  rule_number = 150
  rule_action = "allow"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_block  = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "private_nat_gateway_http_egress" {
  network_acl_id = aws_network_acl.private.id

  egress      = true
  rule_number = 151
  rule_action = "allow"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_block  = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "private_nat_gateway_ephemeral_ingress" {
  network_acl_id = aws_network_acl.private.id

  egress      = false
  rule_number = 200
  rule_action = "allow"
  from_port   = 1024
  to_port     = 65535
  protocol    = "tcp"
  cidr_block  = "0.0.0.0/0"
}
