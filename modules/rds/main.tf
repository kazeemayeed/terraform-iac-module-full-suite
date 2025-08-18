# Random password for RDS
resource "random_password" "master_password" {
  count = var.manage_master_user_password ? 0 : 1

  length  = var.master_password_length
  special = true
}

# RDS Subnet Group (if not provided)
resource "aws_db_subnet_group" "main" {
  count = var.db_subnet_group_name == "" ? 1 : 0

  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
    }
  )
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  count = var.create_db_parameter_group ? 1 : 0

  family = var.parameter_group_family
  name   = "${var.name_prefix}-db-parameter-group"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-parameter-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Option Group
resource "aws_db_option_group" "main" {
  count = var.create_db_option_group ? 1 : 0

  name                     = "${var.name_prefix}-db-option-group"
  option_group_description = "Option group for ${var.name_prefix}"
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version

  dynamic "option" {
    for_each = var.options
    content {
      option_name = option.value.option_name

      dynamic "option_settings" {
        for_each = option.value.option_settings
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-option-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = var.identifier != "" ? var.identifier : "${var.name_prefix}-db"

  # Engine
  engine         = var.engine
  engine_version = var.engine_version

  # Instance
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  # Database
  db_name  = var.database_name
  username = var.master_username
  password = var.manage_master_user_password ? null : (var.master_password != "" ? var.master_password : random_password.master_password[0].result)

  manage_master_user_password = var.manage_master_user_password

  # Network
  db_subnet_group_name   = var.db_subnet_group_name != "" ? var.db_subnet_group_name : aws_db_subnet_group.main[0].name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible
  port                   = var.port

  # Parameter and Option Groups
  parameter_group_name = var.create_db_parameter_group ? aws_db_parameter_group.main[0].name : var.parameter_group_name
  option_group_name    = var.create_db_option_group ? aws_db_option_group.main[0].name : var.option_group_name

  # Backup
  backup_retention_period   = var.backup_retention_period
  backup_window            = var.backup_window
  copy_tags_to_snapshot    = var.copy_tags_to_snapshot
  delete_automated_backups = var.delete_automated_backups

  # Maintenance
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id      = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  # Deletion
  deletion_protection       = var.deletion_protection
  final_snapshot_identifier = var.final_snapshot_identifier
  skip_final_snapshot       = var.skip_final_snapshot

  # Multi-AZ
  multi_az = var.multi_az

  tags = merge(
    var.tags,
    {
      Name = var.identifier != "" ? var.identifier : "${var.name_prefix}-db"
    }
  )

  lifecycle {
    ignore_changes = [password]
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "main" {
  for_each = toset(var.enabled_cloudwatch_logs_exports)

  name              = "/aws/rds/instance/${aws_db_instance.main.identifier}/${each.value}"
  retention_in_days = var.log_retention_period

  tags = var.tags
}