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
