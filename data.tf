data "terraform_remote_state" "infraestrutura" {
  backend = "remote"

  config = {
    organization = "autocenter-fiap"
    workspaces = {
      name = "infraestrutura"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = "eks-autocenter-fiap-infraestrutura"
}
