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
  region  = "us-east-1"
}

module "networking" {
  source = "./modules/networking"

  tags = var.tags
  up = var.up

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1e"]
}

module "bastion" {
  source = "./modules/bastion"

  tags = var.tags
  up = var.up
  ingress_cidrs = var.home_ips
  vpc_id = module.networking.vpc_id
  subnet_id = module.networking.public_subnet_1_id
  public_key = file("${path.module}/public_key")
}

module "rds" {
  source = "./modules/rds"

  tags = var.tags
  name = "${var.name}_db"
  up = var.up
  vpc_id = module.networking.vpc_id
  subnet_ids = [
    module.networking.private_subnet_1_id,
    module.networking.private_subnet_2_id,
    module.networking.private_subnet_3_id
  ]

  egress_sgs = [module.bastion.sg_id]
  ingress_sgs = [module.bastion.sg_id]
}
