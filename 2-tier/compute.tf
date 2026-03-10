resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-launch-template"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_sg.id]
  }
  user_data = base64encode(templatefile("userdata.tftpl", {
    db_user     = aws_db_instance.database.username
    db_pass     = random_password.db_password.result
    db_endpoint = aws_db_instance.database.address
    db_name     = aws_db_instance.database.db_name
  }))

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.project_tags,
      {
        Name = "Flask-App-ASG-Instance"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.project_tags,
      {
        Name = "Flask-App-Root-Volume"
      }
    )
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  vpc_zone_identifier = [
    aws_subnet.private_app_subnet_1.id,
    aws_subnet.private_app_subnet_2.id
  ]

  target_group_arns         = [aws_lb_target_group.web_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# Monitoring

resource "aws_sns_topic" "alerts" {
  name = "app-threshold-alerts"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "stefmd21@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "high_requests" {
  alarm_name          = "high-request-count-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1000"
  dimensions = {
  }

  alarm_description = "This alarm triggers when the total number of requests exceeds 1000 within a 5-minute period."
  alarm_actions     = [aws_sns_topic.alerts.arn]
}
