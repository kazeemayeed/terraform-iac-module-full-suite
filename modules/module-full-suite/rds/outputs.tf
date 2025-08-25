output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "RDS instance hosted zone ID"
  value       = aws_db_instance.main.hosted_zone_id
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "RDS instance database name"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "RDS instance master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_instance_password" {
  description = "RDS instance master password"
  value       = var.manage_master_user_password ? null : aws_db_instance.main.password
  sensitive   = true
}

output "db_subnet_group_id" {
  description = "DB subnet group name"
  value       = var.db_subnet_group_name != "" ? var.db_subnet_group_name : aws_db_subnet_group.main[0].name
}

output "parameter_group_id" {
  description = "DB parameter group name"
  value       = var.create_db_parameter_group ? aws_db_parameter_group.main[0].name : var.parameter_group_name
}

output "option_group_id" {
  description = "DB option group name"
  value       = var.create_db_option_group ? aws_db_option_group.main[0].name : var.option_group_name
}