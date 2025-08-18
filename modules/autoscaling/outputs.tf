output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = var.enable_scaling_policies ? aws_autoscaling_policy.scale_up[0].arn : null
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = var.enable_scaling_policies ? aws_autoscaling_policy.scale_down[0].arn : null
}

output "target_tracking_policy_arn" {
  description = "ARN of the target tracking policy"
  value       = var.enable_target_tracking ? aws_autoscaling_policy.target_tracking[0].arn : null
}