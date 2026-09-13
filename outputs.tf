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

output "rds_security_group_id" {
  description = "ID do Security Group do RDS MySQL"
  value       = aws_security_group.rds_mysql.id
}