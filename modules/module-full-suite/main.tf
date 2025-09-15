# modules/module-full-suite/main.tf

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
  source = "../module-network"  # Adjust path based on your actual network module location
  
  # Pass required variables to network module
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  # Add any other variables your network module requires
  tags = var.tags
}

# Compute Module Declaration  
module "compute" {
  source = "../module-compute"  # Adjust path based on your actual compute module location
  
  # Pass required variables and dependencies from network module
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  
  # Other compute-specific variables
  instance_type         = var.instance_type
  key_name             = var.key_name
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  
  tags = var.tags
  
  # Ensure compute module waits for network module to complete
  depends_on = [module.network]
}
