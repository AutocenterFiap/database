output "rds_identifier" {
  value = aws_db_instance.mysql.identifier
}

output "rds_endpoint" {
  value     = aws_db_instance.mysql.address
  sensitive = true
}

output "rds_port" {
  value = aws_db_instance.mysql.port
}
