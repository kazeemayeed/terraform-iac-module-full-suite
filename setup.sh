#!/bin/bash

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to generate random suffix
generate_suffix() {
    echo $(openssl rand -hex 4)
}

# Function to create S3 bucket for Terraform state
create_state_bucket() {
    local bucket_name=$1
    local region=$2
    
    print_message $BLUE "Creating S3 bucket for Terraform state: $bucket_name"
    
    # Create bucket
    if [[ "$region" == "us-east-1" ]]; then
        aws s3api create-bucket --bucket "$bucket_name" --region "$region"
    else
        aws s3api create-bucket --bucket "$bucket_name" --region "$region" \
            --create-bucket-configuration LocationConstraint="$region"
    fi
    
    # Enable versioning
    aws s3api put-bucket-versioning --bucket "$bucket_name" \
        --versioning-configuration Status=Enabled
    
    # Enable server-side encryption
    aws s3api put-bucket-encryption --bucket "$bucket_name" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'
    
    # Block public access
    aws s3api put-public-access-block --bucket "$bucket_name" \
        --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
    
    print_message $GREEN "✓ S3 bucket created successfully"
}

# Function to create DynamoDB table for state locking
create_state_table() {
    local table_name=$1
    local region=$2
    
    print_message $BLUE "Creating DynamoDB table for state locking: $table_name"
    
    aws dynamodb create-table \
        --table-name "$table_name" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$region"
    
    # Wait for table to be active
    aws dynamodb wait table-exists --table-name "$table_name" --region "$region"
    
    print_message $GREEN "✓ DynamoDB table created successfully"
}

# Function to update backend configuration
update_backend_config() {
    local bucket_name=$1
    local table_name=$2
    local region=$3
    
    print_message $BLUE "Updating backend configurations..."
    
    # Update backend configuration for each environment
    for env_dir in environments/*/; do
        if [[ -d "$env_dir" ]]; then
            local env_name=$(basename "$env_dir")
            local backend_file="${env_dir}backend.tf"
            
            cat > "$backend_file" << EOF
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

  backend "s3" {
    bucket         = "$bucket_name"
    key            = "$env_name/terraform.tfstate"
    region         = "$region"
    dynamodb_table = "$table_name"
    encrypt        = true
  }
}
EOF
            print_message $GREEN "✓ Updated backend configuration for $env_name"
        fi
    done
}

# Main setup function
main() {
    print_message $GREEN "=== Terraform Infrastructure Setup ==="
    
    # Get AWS region
    local region=$(aws configure get region)
    if [[ -z "$region" ]]; then
        region="us-west-2"
        print_message $YELLOW "No default region found, using: $region"
    else
        print_message $BLUE "Using AWS region: $region"
    fi
    
    # Generate unique names
    local suffix=$(generate_suffix)
    local bucket_name="terraform-state-${suffix}"
    local table_name="terraform-state-lock-${suffix}"
    
    print_message $BLUE "Generated names:"
    print_message $BLUE "  S3 Bucket: $bucket_name"
    print_message $BLUE "  DynamoDB Table: $table_name"
    
    # Create resources
    create_state_bucket "$bucket_name" "$region"
    create_state_table "$table_name" "$region"
    update_backend_config "$bucket_name" "$table_name" "$region"
    
    print_message $GREEN "=== Setup completed successfully ==="
    print_message $YELLOW "Next steps:"
    print_message $YELLOW "1. Review and customize the variables in environments/<env>/terraform.tfvars"
    print_message $YELLOW "2. Run: ./deploy.sh <environment> <action>"
    print_message $YELLOW "   Example: ./deploy.sh dev plan"
    print_message $YELLOW "   Example: ./deploy.sh prod apply"
}

# Check if AWS CLI is installed and configured
if ! command -v aws &> /dev/null; then
    print_message $RED "Error: AWS CLI is not installed"
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    print_message $RED "Error: AWS credentials not configured"
    exit 1
fi

# Run main function
main "$@"