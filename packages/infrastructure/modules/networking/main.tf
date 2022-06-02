locals {
  // Each entry has a collection of ranges per availability zone
  az_subnet_ranges = [
    for cr in cidrsubnets(var.cidr, [for _ in var.availability_zones : 2]...)
    : cidrsubnets(cr, 2, 2)
  ]

  public_subnet_ranges = [
    for cr in local.az_subnet_ranges
    : cr[0]
  ]

  private_subnet_ranges = [
    for cr in local.az_subnet_ranges
    : cr[1]
  ]

  used_azs = min(var.availability_zone_limit, length(var.availability_zones))
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = var.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = var.tags
}

## We leave the default blank to deny all traffic
## We will define an explicit ACL for each subnet type
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id
}
