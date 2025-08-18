output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.main.latest_version
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = var.create_key_pair ? aws_key_pair.main[0].key_name : var.key_name
}

output "instance_id" {
  description = "ID of the single instance (if created)"
  value       = var.create_single_instance ? aws_instance.main[0].id : null
}

output "instance_public_ip" {
  description = "Public IP of the single instance"
  value       = var.create_single_instance ? aws_instance.main[0].public_ip : null
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = var.create_single_instance && var.associate_public_ip ? aws_eip.main[0].public_ip : null
}