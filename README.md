# Terraform Full Suite Module

This Terraform module deploys a full suite of infrastructure resources. It is designed to be reusable and composable within your Terraform projects.

## Prerequisites

Before using this module, ensure you have:

1. **AWS CLI configured** with appropriate permissions
2. **AWS Key Pair created** in your target region:
   ```bash
   # Create a key pair (if you don't have one)
   aws ec2 create-key-pair --key-name my-terraform-key --query 'KeyMaterial' --output text > my-terraform-key.pem
   chmod 400 my-terraform-key.pem
   ```

## Usage

### Terraform Registry (Recommended)

```hcl
module "full_suite" {
  source  = "kazeemayeed/module-full-suite/iac"
  version = "1.6.0"
  
  # Required: Your AWS key pair name
  key_name = "my-terraform-key"
}
```

### GitHub Source

```hcl
module "full_suite" {
  source = "github.com/kazeemayeed/terraform-iac-module-full-suite//modules/module-full-suite"
  
  # Required: Your AWS key pair name  
  key_name = "my-terraform-key"
}
```

## Complete Example

```hcl
provider "aws" {
  region = "us-east-1"
}

module "full_suite" {
  source  = "kazeemayeed/module-full-suite/iac"
  version = "1.6.0"
  
  # Required variables
  key_name = "my-terraform-key"
  
  # Optional variables (with defaults)
  environment = "dev"
  region      = "us-east-1"
}

# Output the VPC ID
output "vpc_id" {
  value = module.full_suite.vpc_id
}
```

## Inputs

| Name          | Description                                    | Type   | Default       | Required |
| ------------- | ---------------------------------------------- | ------ | ------------- | :------: |
| `key_name`    | Name of the AWS key pair for EC2 instances    | string | -             |   yes    |
| `environment` | Environment name (e.g., dev, prod)            | string | `"dev"`       |    no    |
| `region`      | AWS region to deploy resources                 | string | `"us-east-1"` |    no    |

## Outputs

| Name                 | Description               |
| -------------------- | ------------------------- |
| `vpc_id`             | The ID of the VPC created |
| `subnet_ids`         | List of subnet IDs        |
| `security_group_ids` | List of security groups   |

## SSH Access

This module creates EC2 instances with SSH access using the specified key pair. Make sure you have access to the private key file corresponding to the `key_name` you specify.

## Requirements

- Terraform >= 1.0
- AWS Provider ~> 5.0
- Valid AWS credentials configured
- Existing AWS key pair in the target region
