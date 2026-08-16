data "terraform_remote_state" "infraestrutura" {
  backend = "remote"

  config = {
    organization = "autocenter-fiap"
    workspaces = {
      name = "infraestrutura"
    }
  }
}

data "aws_security_group" "eks" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.infraestrutura.outputs.vpc_id]
  }

  filter {
    name   = "group-name"
    values = [var.eks_security_group_name]
  }
}
