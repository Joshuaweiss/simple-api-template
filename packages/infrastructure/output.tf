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
