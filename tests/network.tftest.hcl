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

run "planeja_duas_subredes_privadas" {
  command = plan

  variables {
    db_name     = "autocenter"
    db_username = "dbadmin"
    db_password = "SenhaSegura123!"
  }

  assert {
    condition     = length(aws_subnet.rds_private) == 2
    error_message = "Rede RDS deve criar exatamente duas sub-redes privadas."
  }

  assert {
    condition     = alltrue([for subnet in aws_subnet.rds_private : !subnet.map_public_ip_on_launch])
    error_message = "Sub-redes RDS nao podem atribuir IP publico."
  }
}

run "aplica_grupo_com_duas_subredes" {
  command = apply

  variables {
    db_name     = "autocenter"
    db_username = "dbadmin"
    db_password = "SenhaSegura123!"
  }

  assert {
    condition     = length(aws_db_subnet_group.rds.subnet_ids) == 2
    error_message = "Grupo RDS deve usar duas sub-redes."
  }
}
