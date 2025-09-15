# modules/module-full-suite/variables.tf

# Network Module Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# Compute Module Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "AWS Key Pair name for EC2 instances"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 2
}

# Common Variables
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "terraform-full-suite"
    ManagedBy   = "terraform"
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-full-suite"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
