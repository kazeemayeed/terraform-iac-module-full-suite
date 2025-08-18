variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

variable "create_custom_policy" {
  description = "Create custom IAM policy"
  type        = bool
  default     = true
}

variable "additional_policy_statements" {
  description = "Additional policy statements for custom policy"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = any
  }))
  default = []
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs for access"
  type        = list(string)
  default     = []
}

variable "enable_ssm_access" {
  description = "Enable Systems Manager access"
  type        = bool
  default     = false
}

variable "create_autoscaling_role" {
  description = "Create Auto Scaling service role"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}