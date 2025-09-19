# outputs.tf
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id  # Direct resource reference
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name  # Direct resource reference
}

output "website_url" {
  description = "URL of the website"
  value       = "http://${aws_lb.main.dns_name}"
}
