# Web Server Security Group
resource "aws_security_group" "web" {
  name_prefix = "${var.name_prefix}-web-"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.web_ingress_cidrs
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.web_ingress_cidrs
  }

  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_ingress_cidrs
    }
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
      Name = "${var.name_prefix}-web-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  count = var.enable_http_listener ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.redirect_http_to_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.redirect_http_to_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.main.arn
    }
  }

  tags = var.tags
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count = var.enable_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = var.tags
}

# Additional Target Groups
resource "aws_lb_target_group" "additional" {
  count = length(var.additional_target_groups)

  name     = "${var.name_prefix}-tg-${var.additional_target_groups[count.index].name}"
  port     = var.additional_target_groups[count.index].port
  protocol = var.additional_target_groups[count.index].protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = var.additional_target_groups[count.index].health_check_healthy_threshold
    unhealthy_threshold = var.additional_target_groups[count.index].health_check_unhealthy_threshold
    timeout             = var.additional_target_groups[count.index].health_check_timeout
    interval            = var.additional_target_groups[count.index].health_check_interval
    path                = var.additional_target_groups[count.index].health_check_path
    matcher             = var.additional_target_groups[count.index].health_check_matcher
    port                = var.additional_target_groups[count.index].health_check_port
    protocol            = var.additional_target_groups[count.index].health_check_protocol
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-tg-${var.additional_target_groups[count.index].name}"
    }
  )
}