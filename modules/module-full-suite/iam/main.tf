# EC2 Instance Role
resource "aws_iam_role" "ec2_role" {
  name = "${var.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = var.tags
}

# Attach AWS Managed Policies
resource "aws_iam_role_policy_attachment" "ec2_managed_policies" {
  count = length(var.managed_policy_arns)

  role       = aws_iam_role.ec2_role.name
  policy_arn = var.managed_policy_arns[count.index]
}

# Custom IAM Policy for EC2
resource "aws_iam_role_policy" "ec2_custom_policy" {
  count = var.create_custom_policy ? 1 : 0

  name = "${var.name_prefix}-ec2-custom-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "*"
      }
    ], var.additional_policy_statements)
  })
}

# S3 Access Policy (if S3 access is needed)
resource "aws_iam_role_policy" "s3_access" {
  count = length(var.s3_bucket_arns) > 0 ? 1 : 0

  name = "${var.name_prefix}-s3-access-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = flatten([
          var.s3_bucket_arns,
          [for arn in var.s3_bucket_arns : "${arn}/*"]
        ])
      }
    ]
  })
}

# Systems Manager (SSM) Access
resource "aws_iam_role_policy" "ssm_access" {
  count = var.enable_ssm_access ? 1 : 0

  name = "${var.name_prefix}-ssm-access-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:PutParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${var.name_prefix}/*"
      }
    ]
  })
}

# Auto Scaling Service Role (if needed)
resource "aws_iam_role" "autoscaling_role" {
  count = var.create_autoscaling_role ? 1 : 0

  name = "${var.name_prefix}-autoscaling-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "autoscaling.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "autoscaling_policy" {
  count = var.create_autoscaling_role ? 1 : 0

  role       = aws_iam_role.autoscaling_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"
}