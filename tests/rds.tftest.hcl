mock_provider "aws" {}

override_data {
  target = data.terraform_remote_state.infraestrutura
  values = {
    outputs = {
      vpc_id = "vpc-0123456789abcdef0"
    }
  }
}

override_data {
  target = data.aws_eks_cluster.cluster
  values = {
    vpc_config = [
      {
        cluster_security_group_id = "sg-0123456789abcdef0"
      }
    ]
  }
}

run "cria_mysql_privado_free_tier" {
  command = plan

  variables {
    db_name     = "autocenter"
    db_username = "dbadmin"
    db_password = "SenhaSegura123!"
  }

  assert {
    condition     = aws_db_instance.mysql.instance_class == "db.t4g.micro"
    error_message = "Instancia deve usar db.t4g.micro."
  }

  assert {
    condition     = aws_db_instance.mysql.allocated_storage == 20 && aws_db_instance.mysql.storage_type == "gp3"
    error_message = "MySQL deve usar 20 GiB gp3."
  }

  assert {
    condition     = !aws_db_instance.mysql.publicly_accessible && !aws_db_instance.mysql.multi_az
    error_message = "RDS deve ser privado e sem Multi-AZ."
  }

  assert {
    condition     = aws_db_instance.mysql.backup_retention_period == 0 && aws_db_instance.mysql.skip_final_snapshot
    error_message = "Backups e snapshot final devem estar desabilitados."
  }

  assert {
    condition = (
      length(aws_security_group.rds_mysql.ingress) == 1 &&
      alltrue([
        for rule in aws_security_group.rds_mysql.ingress :
        rule.protocol == "tcp" &&
        rule.from_port == 3306 &&
        rule.to_port == 3306 &&
        try(toset(rule.security_groups), toset([])) == toset([data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]) &&
        try(length(rule.cidr_blocks), 0) == 0 &&
        try(length(rule.ipv6_cidr_blocks), 0) == 0 &&
        try(length(rule.prefix_list_ids), 0) == 0 &&
        !coalesce(try(rule.self, false), false)
      ])
    )
    error_message = "Grupo de seguranca do RDS deve permitir somente TCP/3306 a partir do security group do EKS."
  }

  assert {
    condition     = aws_db_instance.mysql.port == 3306
    error_message = "RDS deve usar a porta 3306."
  }

  assert {
    condition     = !aws_db_instance.mysql.deletion_protection
    error_message = "RDS deve manter deletion_protection desabilitado."
  }
}

run "aplica_somente_sg_dedicado_no_rds" {
  command = apply

  variables {
    db_name     = "autocenter"
    db_username = "dbadmin"
    db_password = "SenhaSegura123!"
  }

  assert {
    condition     = toset(aws_db_instance.mysql.vpc_security_group_ids) == toset([aws_security_group.rds_mysql.id])
    error_message = "Instancia RDS deve anexar somente o security group dedicado do RDS."
  }
}
