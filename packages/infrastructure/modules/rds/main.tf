resource "aws_db_subnet_group" "subnet_group" {
  name = var.name

  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "random_password" "db_master_pass" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>?"
  keepers = {
    pass_version = 20
  }
}

resource "random_id" "password_id_rand" {
	  byte_length = 8
}

resource "aws_secretsmanager_secret" "db_pass_secret" {
  name = "${var.name}_db_password_${random_id.password_id_rand.hex}"
}

resource "aws_secretsmanager_secret_version" "db-pass-val" {
  secret_id     = aws_secretsmanager_secret.db_pass_secret.id
  secret_string = random_password.db_master_pass.result
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier      = replace(var.name, "_", "-")
  engine                  = "aurora-postgresql"
  engine_version          = "13.6"
  availability_zones      = var.availability_zones
  database_name           = var.name
  master_username         = "master"
  master_password         = random_password.db_master_pass.result
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds-sg.id]
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                = var.up ? 1 : 0
  identifier           = "${replace(var.name, "_", "-")}-${count.index}"
  cluster_identifier   = aws_rds_cluster.rds_cluster.id
  instance_class       = "db.t3.medium"
  engine               = aws_rds_cluster.rds_cluster.engine
  engine_version       = aws_rds_cluster.rds_cluster.engine_version
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  availability_zone    = var.availability_zones[count.index]
}

resource "aws_security_group" "rds-sg" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    { Name = "${var.name}_rds" }
  )
}

resource "aws_security_group_rule" "rds-sg-egress" {
  count = length(var.egress_sgs)
  security_group_id = aws_security_group.rds-sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  description       = "Egress RDS traffic"
  source_security_group_id = var.egress_sgs[count.index]
}

resource "aws_security_group_rule" "rds-sg-ingress" {
  count = length(var.ingress_sgs)
  security_group_id = aws_security_group.rds-sg.id
  type              = "ingress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  description       = "Ingress RDS traffic"
  source_security_group_id = var.ingress_sgs[count.index]
}
