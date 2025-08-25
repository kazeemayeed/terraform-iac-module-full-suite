terraform-iac-module-full-suite/modules/module-full-suite/README.md
markdown
Copy
Edit
# Terraform Full Suite Module

This Terraform module deploys a **full suite of infrastructure resources**. It is designed to be reusable and composable within your Terraform projects.

## Usage

```hcl
module "full_suite" {
  source  = "github.com/kazeemayeed/terraform-iac-module-full-suite//modules/module-full-suite"
  version = "1.5.0"

  # Example input variables
  environment = "dev"
  region      = "us-east-1"
}
**Inputs**

| Name          | Description                        | Type   | Default       | Required |
| ------------- | ---------------------------------- | ------ | ------------- | -------- |
| `environment` | Environment name (e.g., dev, prod) | string | `"dev"`       | no       |
| `region`      | AWS region to deploy resources     | string | `"us-east-1"` | no       |

**Outputs**

| Name                 | Description               |
| -------------------- | ------------------------- |
| `vpc_id`             | The ID of the VPC created |
| `subnet_ids`         | List of subnet IDs        |
| `security_group_ids` | List of security groups   |


Example
provider "aws" {
  region = "us-east-1"
}

module "full_suite" {
  source      = "github.com/kazeemayeed/terraform-iac-module-full-suite//modules/module-full-suite"
  version     = "1.5.0"
  environment = "dev"
  region      = "us-east-1"
}

