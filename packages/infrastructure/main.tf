terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.10"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  tags = var.tags
  up = var.up

  cidr = var.cidr

  availability_zones = var.aws_azs
}

module "bastion" {
  source = "./modules/bastion"

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
  name = "${var.name}_db"
  up = var.up
  vpc_id = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  egress_sgs = [module.bastion.sg_id]
  ingress_sgs = [module.bastion.sg_id]
}
