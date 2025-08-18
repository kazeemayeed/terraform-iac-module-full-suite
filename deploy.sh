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

# Function to check if required tools are installed
check_requirements() {
    print_message $BLUE "Checking requirements..."
    
    if ! command -v terraform &> /dev/null; then
        print_message $RED "Error: Terraform is not installed"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        print_message $RED "Error: AWS CLI is not installed"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_message $RED "Error: AWS credentials not configured"
        exit 1
    fi
    
    print_message $GREEN "✓ All requirements satisfied"
}

# Function to initialize Terraform
terraform_init() {
    local env_dir=$1
    print_message $BLUE "Initializing Terraform for $env_dir..."
    cd "environments/$env_dir"
    terraform init -upgrade
    cd ../..
}

# Function to validate Terraform configuration
terraform_validate() {
    local env_dir=$1
    print_message $BLUE "Validating Terraform configuration for $env_dir..."
    cd "environments/$env_dir"
    terraform validate
    cd ../..
}

# Function to plan Terraform deployment
terraform_plan() {
    local env_dir=$1
    print_message $BLUE "Planning Terraform deployment for $env_dir..."
    cd "environments/$env_dir"
    terraform plan -out=tfplan
    cd ../..
}

# Function to apply Terraform deployment
terraform_apply() {
    local env_dir=$1
    print_message $BLUE "Applying Terraform deployment for $env_dir..."
    cd "environments/$env_dir"
    terraform apply tfplan
    rm -f tfplan
    cd ../..
}

# Function to destroy Terraform deployment
terraform_destroy() {
    local env_dir=$1
    print_message $YELLOW "WARNING: This will destroy all resources in $env_dir environment!"
    read -p "Are you sure? (yes/no): " confirmation
    
    if [[ $confirmation == "yes" ]]; then
        print_message $BLUE "Destroying Terraform deployment for $env_dir..."
        cd "environments/$env_dir"
        terraform destroy -auto-approve
        cd ../..
    else
        print_message $YELLOW "Destroy cancelled"
        exit 0
    fi
}

# Function to show Terraform outputs
terraform_output() {
    local env_dir=$1
    print_message $BLUE "Terraform outputs for $env_dir:"
    cd "environments/$env_dir"
    terraform output
    cd ../..
}

# Main script logic
main() {
    print_message $GREEN "=== Terraform Deployment Script ==="
    
    # Check if environment parameter is provided
    if [[ $# -eq 0 ]]; then
        print_message $YELLOW "Usage: $0 <environment> [action]"
        print_message $YELLOW "Environments: dev, staging, prod"
        print_message $YELLOW "Actions: init, validate, plan, apply, destroy, output"
        print_message $YELLOW "Example: $0 dev plan"
        exit 1
    fi
    
    local environment=$1
    local action=${2:-plan}
    
    # Validate environment
    if [[ ! -d "environments/$environment" ]]; then
        print_message $RED "Error: Environment '$environment' not found"
        print_message $YELLOW "Available environments:"
        ls -1 environments/
        exit 1
    fi
    
    # Check requirements
    check_requirements
    
    # Execute action
    case $action in
        init)
            terraform_init $environment
            ;;
        validate)
            terraform_init $environment
            terraform_validate $environment
            ;;
        plan)
            terraform_init $environment
            terraform_validate $environment
            terraform_plan $environment
            ;;
        apply)
            terraform_init $environment
            terraform_validate $environment
            terraform_plan $environment
            terraform_apply $environment
            terraform_output $environment
            ;;
        destroy)
            terraform_destroy $environment
            ;;
        output)
            terraform_output $environment
            ;;
        *)
            print_message $RED "Error: Unknown action '$action'"
            print_message $YELLOW "Available actions: init, validate, plan, apply, destroy, output"
            exit 1
            ;;
    esac
    
    print_message $GREEN "=== Script completed successfully ==="
}

# Run main function with all arguments
main "$@"