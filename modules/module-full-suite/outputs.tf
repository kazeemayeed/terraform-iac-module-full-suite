# modules/module-full-suite/outputs.tf

# Network Module Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.compute.load_balancer_dns
}

output "website_url" {
  description = "URL to access the website"
  value       = "http://${module.compute.load_balancer_dns}"
}

# Additional useful outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}

output "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = try(module.compute.auto_scaling_group_arn, null)
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(module.compute.security_group_id, null)
}
