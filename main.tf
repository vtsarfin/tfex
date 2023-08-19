provider "aws" {
  #   region  = "us-east-2"
  #profile = "test"
}

#launch_configuration

resource "aws_launch_configuration" "main" {
  image_id        = "ami-0989fb15ce71ba39e"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.instance.id]
  key_name        = "vt_id_rsa_aws_t1"
  name_prefix     = var.prefix_u
  user_data       = <<-EOF
              #!/bin/bash
              echo "E, Vadim, kak dela?" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  # Required when using a launch configuration with an ASG.
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_autoscaling_group" "main" {
  launch_configuration = aws_launch_configuration.main.name
  min_size             = 2
  max_size             = 3
  vpc_zone_identifier  = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.asg.arn]
  health_check_type    = "ELB"
  name_prefix          = var.prefix_u
  tag {
    key                 = "Name"
    value               = var.prefix_u
    propagate_at_launch = true
  }
  provisioner "local-exec" {
    command = "aws ec2 describe-instances --filters Name=tag:Name,Values=${var.prefix_u}\\* --query 'Reservations[*].Instances[*].{\"private_ip\":PrivateIpAddress,\"public_ip\":PublicIpAddress}' > my_info.txt"
  }

}

resource "aws_security_group" "alb" {
  name = "${var.prefix_u}-asg"
  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_lb" "main" {
  name               = "${var.prefix_u}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}


resource "aws_lb_target_group" "asg" {
  name     = "${var.prefix_u}-asg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_security_group" "instance" {
  name = "${var.prefix_u}-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The domain name of the load balancer"
}
output "aws_autoscaling_group_name" {
  value       = aws_autoscaling_group.main.name
  description = "i try ===>>>"
}

