terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Network Module Declaration
module "network" {
  source = "../network"
  
  # Pass required variables to network module
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
  project_name         = var.project_name
  
  tags = merge(var.tags, {
    Module = "network"
  })
}

# Compute Module Declaration  
module "compute" {
  source = "../compute"
  
  # Pass required variables and dependencies from network module
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  
  # Other compute-specific variables
  instance_type    = var.instance_type
  key_name        = var.key_name
  min_size        = var.min_size
  max_size        = var.max_size
  desired_capacity = var.desired_capacity
  environment     = var.environment
  project_name    = var.project_name
  
  tags = merge(var.tags, {
    Module = "compute"
  })
  
  # Ensure compute module waits for network module to complete
  depends_on = [module.network]
}
