# --- Launch Template ---

resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}-web-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  vpc_security_group_ids = [aws_security_group.ec2.id]

  # Enforce IMDSv2 — prevents SSRF-based metadata credential theft
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y httpd amazon-cloudwatch-agent

    systemctl enable --now httpd

    IMDS_TOKEN=$(curl -sf -X PUT http://169.254.169.254/latest/api/token \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -sf -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -sf -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" \
      http://169.254.169.254/latest/meta-data/placement/availability-zone)

    cat > /var/www/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
      <head><title>${local.name_prefix}</title></head>
      <body style="font-family:monospace;background:#0d1117;color:#58a6ff;padding:3rem">
        <h2 style="color:#f0f6fc">${local.name_prefix} / ${var.environment}</h2>
        <p>Instance &nbsp;: $INSTANCE_ID</p>
        <p>AZ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: $AZ</p>
        <p>AMI &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ${data.aws_ami.amazon_linux_2023.id}</p>
        <p style="color:#3fb950;margin-top:2rem">&#10003; Healthy</p>
      </body>
    </html>
    HTML
  USERDATA
  )

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.common_tags, { Name = "${local.name_prefix}-web" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.common_tags, { Name = "${local.name_prefix}-web-vol" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- Application Load Balancer ---

resource "aws_lb" "web" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = values(aws_subnet.public)[*].id

  enable_deletion_protection = false

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-alb" })
}

resource "aws_lb_target_group" "web" {
  name        = "${local.name_prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-tg" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# --- Auto Scaling Group ---

resource "aws_autoscaling_group" "web" {
  name                      = "${local.name_prefix}-asg"
  desired_capacity          = var.asg_desired
  min_size                  = var.asg_min
  max_size                  = var.asg_max
  vpc_zone_identifier       = values(aws_subnet.private)[*].id
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  # Zero-downtime rolling deployments
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 60
    }
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, { Name = "${local.name_prefix}-web" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- Scaling Policies (CPU-based) ---

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${local.name_prefix}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${local.name_prefix}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}
