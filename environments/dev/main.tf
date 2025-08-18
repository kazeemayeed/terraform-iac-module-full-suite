terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# VPC
module "vpc" {
  source = "../../modules/vpc"

  name_prefix        = "${var.project_name}-${var.environment}"
  vpc_cidr          = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  
  enable_nat_gateway = var.enable_nat_gateway
  enable_flow_log   = var.enable_vpc_flow_log
  
  tags = local.common_tags
}

# Security Groups
module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix           = "${var.project_name}-${var.environment}"
  vpc_id               = module.vpc.vpc_id
  enable_ssh           = var.enable_ssh
  create_database_sg   = var.create_database_sg
  create_cache_sg      = var.create_cache_sg
  ssh_ingress_cidrs    = var.ssh_ingress_cidrs
  
  tags = local.common_tags
}

# IAM
module "iam" {
  source = "../../modules/iam"

  name_prefix           = "${var.project_name}-${var.environment}"
  enable_ssm_access    = var.enable_ssm_access
  create_autoscaling_role = var.create_autoscaling_role
  
  tags = local.common_tags
}

# EC2 Launch Template
module "ec2" {
  source = "../../modules/ec2"

  name_prefix           = "${var.project_name}-${var.environment}"
  instance_type        = var.instance_type
  security_group_ids   = [module.security_groups.web_security_group_id]
  subnet_ids          = module.vpc.private_subnet_ids
  instance_profile_name = module.iam.ec2_instance_profile_name
  user_data           = base64encode(templatefile("${path.module}/userdata.sh", {
    environment = var.environment
  }))
  
  enable_detailed_monitoring = var.enable_detailed_monitoring
  
  tags = local.common_tags
}

# Application Load Balancer
module "alb" {
  source = "../../modules/alb"

  name_prefix        = "${var.project_name}-${var.environment}"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.alb_security_group_id]
  
  enable_access_logs = var.enable_alb_access_logs
  access_logs_bucket = var.alb_access_logs_bucket
  
  tags = local.common_tags
}

# Auto Scaling Group
module "autoscaling" {
  source = "../../modules/autoscaling"

  name_prefix          = "${var.project_name}-${var.environment}"
  subnet_ids          = module.vpc.private_subnet_ids
  target_group_arns   = [module.alb.target_group_arn]
  launch_template_id  = module.ec2.launch_template_id
  
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  
  enable_scaling_policies = var.enable_scaling_policies
  
  tags = local.common_tags
}

# RDS (optional)
module "rds" {
  count = var.create_rds ? 1 : 0
  source = "../../modules/rds"

  name_prefix            = "${var.project_name}-${var.environment}"
  engine                = var.rds_engine
  engine_version        = var.rds_engine_version
  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  
  database_name         = var.rds_database_name
  master_username       = var.rds_master_username
  
  subnet_ids            = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.security_groups.database_security_group_id]
  
  backup_retention_period = var.rds_backup_retention_period
  multi_az              = var.rds_multi_az
  deletion_protection   = var.rds_deletion_protection
  
  tags = local.common_tags
}

# S3 Bucket for application assets (optional)
module "s3" {
  count = var.create_s3_bucket ? 1 : 0
  source = "../../modules/s3"

  name_prefix       = "${var.project_name}-${var.environment}"
  versioning_enabled = var.s3_versioning_enabled
  
  tags = local.common_tags
}