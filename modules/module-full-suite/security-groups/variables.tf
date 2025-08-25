variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "web_ingress_cidrs" {
  description = "CIDR blocks allowed to access web servers"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_ingress_cidrs" {
  description = "CIDR blocks allowed to access load balancer"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_ingress_cidrs" {
  description = "CIDR blocks allowed SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_ssh" {
  description = "Enable SSH access to web servers"
  type        = bool
  default     = false
}

variable "create_database_sg" {
  description = "Create database security group"
  type        = bool
  default     = false
}

variable "create_cache_sg" {
  description = "Create cache security group"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
