locals {
  rds_subnets = {
    for index, cidr in var.private_subnet_cidrs :
    var.availability_zones[index] => cidr
  }
}

resource "aws_subnet" "rds_private" {
  for_each = local.rds_subnets

  vpc_id                  = data.terraform_remote_state.infraestrutura.outputs.vpc_id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "autocenter-rds-private-${each.key}"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "autocenter-rds-private"
  subnet_ids = values(aws_subnet.rds_private)[*].id

  tags = {
    Name = "autocenter-rds-private"
  }
}
