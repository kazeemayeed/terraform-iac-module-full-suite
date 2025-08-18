# This file should be copied to each environment directory
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  # Backend configuration - update for each environment
  backend "s3" {
    # bucket         = "your-terraform-state-bucket"  # Update this
    # key            = "dev/terraform.tfstate"        # Update this
    # region         = "us-west-2"                    # Update this
    # dynamodb_table = "terraform-state-lock"        # Update this
    # encrypt        = true
  }
}