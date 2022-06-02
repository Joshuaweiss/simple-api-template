terraform {
  required_version = ">= 0.14.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.10"
    }

    random = {
      source = "hashicorp/random"
      version = "3.2.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

module "networking" {
  name = var.name

  source = "./modules/networking"

  tags = var.tags
  up = var.up

  cidr = var.cidr

  availability_zones = var.aws_azs
  availability_zone_limit = var.limit_azs

  ssh_cidrs = var.home_ips
}

module "bastion" {
  source = "./modules/bastion"

  name = var.name
  tags = var.tags
  up = var.up
  ingress_cidrs = var.home_ips
  vpc_id = module.networking.vpc_id
  subnet_id = module.networking.public_subnet_ids[0]
  public_key = file("${path.module}/public_key")
}

module "rds" {
  source = "./modules/rds"

  tags = var.tags
  name = var.name
  up = var.up
  vpc_id = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  availability_zones = var.aws_azs

  egress_sgs = [
    module.bastion.sg_id,
    aws_security_group.api-sg.id
  ]
  ingress_sgs = [
    module.bastion.sg_id,
    aws_security_group.api-sg.id
  ]
}

resource "aws_security_group" "api-sg" {
  vpc_id = module.networking.vpc_id

  tags = merge(
    var.tags,
    { Name = "${var.name}_api" }
  )
}

resource "aws_security_group_rule" "api-egress" {
  security_group_id = aws_security_group.api-sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  description       = "Egress Lambda traffic"
  cidr_blocks       = ["0.0.0.0/0"]
}
