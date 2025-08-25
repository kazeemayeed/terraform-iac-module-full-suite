**About**

This repository offers a collection of Terraform modules that encapsulate common infrastructure patterns and services. By leveraging these modules, users can quickly deploy standardized and repeatable infrastructure components across various cloud providers.

**Features**

Modular Design: Each module is self-contained, focusing on a specific resource or service, ensuring clarity and reusability.

Cross-Platform Compatibility: Designed to work seamlessly with multiple cloud providers, including AWS, Azure, and GCP.

Scalable Architecture: Built with scalability in mind, allowing users to easily extend and adapt modules to their needs.

Best Practices: Incorporates Terraform best practices, including proper state management, variable usage, and output definitions.

**Modules Included**

The suite includes modules for:

Compute Resources: EC2 instances, virtual machines, and autoscaling groups.

Networking: VPCs, subnets, security groups, and load balancers.

Storage: S3 buckets, Azure Blob Storage, and Google Cloud Storage.

Identity & Access Management: IAM roles, policies, and service accounts.

Databases: RDS, DynamoDB, and Cloud SQL instances.

Monitoring & Logging: CloudWatch, Azure Monitor, and Stackdriver configurations.

**Usage**

To utilize a module from this suite, follow these steps:

Clone the Repository:

git clone https://github.com/kazeemayeed/terraform-iac-module-full-suite.git
cd terraform-iac-module-full-suite


Navigate to the Desired Module:

cd modules/<module-name>


Initialize Terraform:

terraform init


Configure Variables:

Copy the terraform.tfvars.example file to terraform.tfvars and modify the values as needed.

cp terraform.tfvars.example terraform.tfvars


Plan the Deployment:

terraform plan


Apply the Configuration:

terraform apply

**Example**

Here's an example of how to use the EC2 module:

module "ec2_instance" {
  source = "../modules/aws/ec2"

  instance_type = "t2.micro"
  ami_id        = "ami-0c55b159cbfafe1f0"
  region        = "us-east-1"
}

**Requirements**

Terraform v1.0 or higher

AWS CLI configured with appropriate credentials

Access to the desired cloud provider's console and API

**Outputs**

Each module provides outputs that can be utilized in other parts of your infrastructure. For example, the EC2 module might output:

output "instance_id" {
  value = aws_instance.this.id
}

**Testing**

To ensure the modules function as expected:

Navigate to the module directory:

cd modules/<module-name>


Initialize Terraform:

terraform init


Apply the configuration:

terraform apply


Verify the resources in your cloud provider's console.

**Documentation**

Detailed documentation for each module is available within the respective module directories. This includes variable definitions, output descriptions, and example configurations.

**Contributing**

Contributions are welcome! Please refer to the CONTRIBUTING.md
 for guidelines on how to contribute to this repository.

**License**

This project is licensed under the Apache-2.0 License - see the LICENSE
 file for details.
