resource "aws_lb" "lb" {
  name               = "deviceme-api-pro"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnets
  tags = {
    "env"       = "pro"
    "createdBy" = "hoaittt"
  }
  security_groups = [aws_security_group.lb.id]
}

resource "aws_security_group" "lb" {
  name   = "DeviceMe-ECS-Pro-LB"
  vpc_id = data.aws_vpc.main.id
  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  #    ingress {
  #   description      = "HTTPS"
  #   from_port        = 49155
  #   to_port          = 49155
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  # }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "env"       = "pro"
    "createdBy" = "hoaittt"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = "prod-deviceme-target-group"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.main.id
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}

# resource "aws_lb_listener" "web-listener" {
#   load_balancer_arn = aws_lb.lb.arn
#   # load_balancer_arn = var.load_balancer_arn
#   port     = "80"
#   protocol = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.lb_target_group.arn
#   }
#   # default_action {
#   #   type = "redirect"

#   #   redirect {
#   #     port        = "443"
#   #     protocol    = "HTTPS"
#   #     status_code = "HTTP_301"
#   #   }
#   # }
# }

resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  # default_action {
  #   target_group_arn = aws_alb_target_group.app.id
  #   type             = "forward"
  # }
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "web-listener-https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.frontend-certificate[0].arn
  # default_action {
  #   type = "redirect"

  #   redirect {
  #     port        = "80"
  #     protocol    = "HTTP"
  #     status_code = "HTTP_301"
  #   }
  # }
  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    type             = "forward"
  }
}
