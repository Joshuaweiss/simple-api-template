output "master_username" {
  value = aws_rds_cluster.rds_cluster.master_username
}

output "database_name" {
  value = aws_rds_cluster.rds_cluster.database_name
}

output "endpoint" {
  value = aws_rds_cluster.rds_cluster.endpoint
}

output "password_secret_id" {
  value = aws_secretsmanager_secret.db_pass_secret.id
}
