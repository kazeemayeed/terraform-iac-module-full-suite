output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = var.create_database_sg ? aws_security_group.database[0].id : null
}

output "cache_security_group_id" {
  description = "ID of the cache security group"
  value       = var.create_cache_sg ? aws_security_group.cache[0].id : null
}