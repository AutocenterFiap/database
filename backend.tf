terraform {
  cloud {
    organization = "autocenter-fiap"

    workspaces {
      name = "database"
    }
  }
}
