terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

module "full_suite" {
  source = "./modules/module-full-suite"
  
  # Required variables
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  key_name          = var.key_name
  
  # Optional variables (override defaults if needed)
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  instance_type        = "t3.micro"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  environment         = var.environment
  project_name        = var.project_name
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Owner       = "DevOps Team"
  }
}

# Outputs from the module
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.full_suite.vpc_id
}

output "website_url" {
  description = "URL to access the website"
  value       = module.full_suite.website_url
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.full_suite.load_balancer_dns
}
