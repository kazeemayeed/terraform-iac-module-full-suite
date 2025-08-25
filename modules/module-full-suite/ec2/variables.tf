variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for instances (empty to use latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of existing key pair to use"
  type        = string
  default     = ""
}

variable "create_key_pair" {
  description = "Create a new key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key content for new key pair"
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = ""
}

variable "create_single_instance" {
  description = "Create a single EC2 instance (not for Auto Scaling)"
  type        = bool
  default     = false
}

variable "associate_public_ip" {
  description = "Associate public IP with single instance"
  type        = bool
  default     = false
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "block_device_mappings" {
  description = "Block device mappings"
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = string
    delete_on_termination = bool
    encrypted             = bool
  }))
  default = [
    {
      device_name           = "/dev/xvda"
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = false
    }
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}