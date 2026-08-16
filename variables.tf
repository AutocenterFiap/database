variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "db_name" {
  type = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,63}$", var.db_name))
    error_message = "db_name deve iniciar com letra e ter ate 64 letras, numeros ou _. "
  }
}

variable "db_username" {
  type      = string
  sensitive = true

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,15}$", var.db_username))
    error_message = "db_username deve iniciar com letra e ter ate 16 letras, numeros ou _. "
  }
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "eks_security_group_name" {
  type    = string
  default = "autocenter-fiap-infraestrutura-sg"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.48.0/20", "10.0.64.0/20"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2 && alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "private_subnet_cidrs deve conter exatamente dois CIDRs validos."
  }
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "availability_zones deve conter exatamente duas zonas."
  }
}
