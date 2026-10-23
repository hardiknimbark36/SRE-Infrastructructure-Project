resource "aws_launch_template" "app_lt" {
  name_prefix   = "sre-app-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>SRE Project - Highly Available!</h1><p>Served from IP: $(hostname -I)</p>" > /var/www/html/index.html
              EOF
  )
}

resource "aws_autoscaling_group" "app_asg" {
  vpc_zone_identifier = [aws_subnet.public.id, aws_subnet.public_2.id]
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = aws_launch_template.app_lt.latest_version # UPDATED THIS LINE
  }
  
  # ADDED THIS BLOCK to automate rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}