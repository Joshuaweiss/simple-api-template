output "aws_region" {
  value = var.aws_region
}

output "master_username" {
  value = module.rds.master_username
}

output "database_name" {
  value = module.rds.database_name
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "bastion_endpoint" {
  value = module.bastion.endpoint
}

output "rds_password_secret_id" {
  value = module.rds.password_secret_id
}

output "private_subnet_ids" {
  value = slice(
    module.networking.private_subnet_ids,
    0,
    min(var.limit_azs, length(module.networking.private_subnet_ids))
  )
}

output "api_sg_id" {
  value = aws_security_group.api-sg.id
}
