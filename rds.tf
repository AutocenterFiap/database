resource "aws_security_group" "rds_mysql" {
  name        = "autocenter-rds-mysql"
  description = "Permite MySQL somente pelo EKS"
  vpc_id      = data.terraform_remote_state.infraestrutura.outputs.vpc_id

  ingress {
    description     = "MySQL pelo EKS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]
  }

  tags = {
    Name = "autocenter-rds-mysql"
  }
}

resource "aws_db_instance" "mysql" {
  identifier              = "autocenter-mysql"
  engine                  = "mysql"
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  storage_type            = "gp3"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = 3306
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds_mysql.id]
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name = "autocenter-mysql"
  }
}
