variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs"
  type        = list(string)
  default     = []
}

variable "launch_template_id" {
  description = "Launch template ID"
  type        = string
}

variable "launch_template_version" {
  description = "Launch template version"
  type        = string
  default     = "$Latest"
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "health_check_type" {
  description = "Health check type"
  type        = string
  default     = "ELB"
}

variable "health_check_grace_period" {
  description = "Health check grace period"
  type        = number
  default     = 300
}

variable "default_cooldown" {
  description = "Default cooldown period"
  type        = number
  default     = 300
}

variable "termination_policies" {
  description = "List of termination policies"
  type        = list(string)
  default     = ["Default"]
}

variable "wait_for_capacity_timeout" {
  description = "Wait for capacity timeout"
  type        = string
  default     = "10m"
}

variable "enable_instance_refresh" {
  description = "Enable instance refresh"
  type        = bool
  default     = false
}

variable "instance_refresh_min_healthy_percentage" {
  description = "Minimum healthy percentage for instance refresh"
  type        = number
  default     = 50
}

variable "instance_refresh_instance_warmup" {
  description = "Instance warmup time for instance refresh"
  type        = number
  default     = 300
}

variable "enabled_metrics" {
  description = "List of enabled metrics"
  type        = list(string)
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
}

variable "enable_scaling_policies" {
  description = "Enable scaling policies"
  type        = bool
  default     = true
}

variable "scale_up_adjustment" {
  description = "Scale up adjustment"
  type        = number
  default     = 1
}

variable "scale_up_cooldown" {
  description = "Scale up cooldown"
  type        = number
  default     = 300
}

variable "scale_down_adjustment" {
  description = "Scale down adjustment"
  type        = number
  default     = -1
}

variable "scale_down_cooldown" {
  description = "Scale down cooldown"
  type        = number
  default     = 300
}

variable "cpu_high_threshold" {
  description = "CPU high threshold"
  type        = number
  default     = 80
}

variable "cpu_high_period" {
  description = "CPU high period"
  type        = number
  default     = 120
}

variable "cpu_high_evaluation_periods" {
  description = "CPU high evaluation periods"
  type        = number
  default     = 2
}

variable "cpu_low_threshold" {
  description = "CPU low threshold"
  type        = number
  default     = 10
}

variable "cpu_low_period" {
  description = "CPU low period"
  type        = number
  default     = 120
}

variable "cpu_low_evaluation_periods" {
  description = "CPU low evaluation periods"
  type        = number
  default     = 2
}

variable "enable_target_tracking" {
  description = "Enable target tracking scaling policy"
  type        = bool
  default     = false
}

variable "target_tracking_metric_type" {
  description = "Target tracking metric type"
  type        = string
  default     = "ASGAverageCPUUtilization"
}

variable "target_tracking_target_value" {
  description = "Target tracking target value"
  type        = number
  default     = 70
}

variable "target_tracking_scale_out_cooldown" {
  description = "Target tracking scale out cooldown"
  type        = number
  default     = 300
}

variable "target_tracking_scale_in_cooldown" {
  description = "Target tracking scale in cooldown"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}