Usage Instructions

Initial Setup:
bash# Make scripts executable
chmod +x setup.sh deploy.sh

# Run initial setup (creates S3 bucket and DynamoDB table for state)
./setup.sh

Deploy to Development:
bash# Plan deployment
./deploy.sh dev plan

# Apply deployment
./deploy.sh dev apply

Deploy to Production:
bash# Copy and customize variables
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars

# Edit the file with your production values
vim environments/prod/terraform.tfvars

# Plan deployment
./deploy.sh prod plan

# Apply deployment
./deploy.sh prod apply

Destroy Resources:
bash./deploy.sh dev destroy

This comprehensive module suite provides:

Production-ready modules with best practices
Multi-environment support (dev, staging, prod)
Complete AWS infrastructure (VPC, ALB, ASG, RDS, S3, etc.)
Security hardening with proper IAM roles and security groups
Automated deployment scripts
State management with S3 backend and DynamoDB locking
Comprehensive documentation and examples
Scalable and maintainable architecture

All modules are fully parameterized and can be easily customized for your specific requirements!
create_before_destroy = true
}
}

# **Application Load Balancer Security Group**

```hcl
resource "aws_security_group" "alb" {
name_prefix = "${var.name_prefix}-alb-"
description = "Security group for Application Load Balancer"
vpc_id      = var.vpc_id
ingress {
description = "HTTP"
from_port   = 80
to_port     = 80
protocol    = "tcp"
cidr_blocks = var.alb_ingress_cidrs
}
ingress {
description = "HTTPS"
from_port   = 443
to_port     = 443
protocol    = "tcp"
cidr_blocks = var.alb_ingress_cidrs
}
egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
tags = merge(
var.tags,
{
Name = "${var.name_prefix}-alb-sg"
}
)
lifecycle {
create_before_destroy = true
}
}
```

# **Database Security Group**

```hcl
resource "aws_security_group" "database" {
count = var.create_database_sg ? 1 : 0
name_prefix = "${var.name_prefix}-database-"
description = "Security group for database servers"
vpc_id      = var.vpc_id
ingress {
description     = "MySQL/Aurora"
from_port       = 3306
to_port         = 3306
protocol        = "tcp"
security_groups = [aws_security_group.web.id]
}
ingress {
description     = "PostgreSQL"
from_port       = 5432
to_port         = 5432
protocol        = "tcp"
security_groups = [aws_security_group.web.id]
}
egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
tags = merge(
var.tags,
{
Name = "${var.name_prefix}-database-sg"
}
)
lifecycle {
create_before_destroy = true
}
}
```

# **Cache Security Group**

```hcl
resource "aws_security_group" "cache" {
count = var.create_cache_sg ? 1 : 0
name_prefix = "${var.name_prefix}-cache-"
description = "Security group for cache servers"
vpc_id      = var.vpc_id
ingress {
description     = "Redis"
from_port       = 6379
to_port         = 6379
protocol        = "tcp"
security_groups = [aws_security_group.web.id]
}
ingress {
description     = "Memcached"
from_port       = 11211
to_port         = 11211
protocol        = "tcp"
security_groups = [aws_security_group.web.id]
}
tags = merge(
var.tags,
{
Name = "${var.name_prefix}-cache-sg"
}
)
lifecycle {
create_before_destroy = true
}
}
```
