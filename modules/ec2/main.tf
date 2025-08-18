# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair
resource "aws_key_pair" "main" {
  count = var.create_key_pair ? 1 : 0

  key_name   = "${var.name_prefix}-key-pair"
  public_key = var.public_key

  tags = var.tags
}

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.name_prefix}-lt-"
  description   = "Launch template for ${var.name_prefix}"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.create_key_pair ? aws_key_pair.main[0].key_name : var.key_name

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = base64encode(var.user_data)

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
        delete_on_termination = block_device_mappings.value.delete_on_termination
        encrypted             = block_device_mappings.value.encrypted
      }
    }
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  dynamic "tag_specifications" {
    for_each = ["instance", "volume"]
    content {
      resource_type = tag_specifications.value
      tags = merge(
        var.tags,
        {
          Name = "${var.name_prefix}-${tag_specifications.value}"
        }
      )
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-launch-template"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Single EC2 Instance (if not using Auto Scaling)
resource "aws_instance" "main" {
  count = var.create_single_instance ? 1 : 0

  ami                     = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type           = var.instance_type
  key_name                = var.create_key_pair ? aws_key_pair.main[0].key_name : var.key_name
  vpc_security_group_ids  = var.security_group_ids
  subnet_id               = var.subnet_ids[0]
  iam_instance_profile    = var.instance_profile_name
  user_data               = var.user_data
  monitoring              = var.enable_detailed_monitoring

  dynamic "root_block_device" {
    for_each = length(var.block_device_mappings) > 0 ? [var.block_device_mappings[0]] : []
    content {
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-instance"
    }
  )
}

# Elastic IP for single instance (optional)
resource "aws_eip" "main" {
  count = var.create_single_instance && var.associate_public_ip ? 1 : 0

  instance = aws_instance.main[0].id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-eip"
    }
  )
}