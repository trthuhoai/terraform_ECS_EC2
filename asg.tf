data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon", "self"]
}

resource "aws_security_group" "ec2-sg" {
  name = "${var.app_name}-${var.environment}-sg"
  # description = "allow"
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
  #   ingress {
  #   description      = "SSH"
  #   from_port        = 22
  #   to_port          = 22
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  #   # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Product DeviceMe API"
  }
}

resource "aws_launch_configuration" "lc" {
  name_prefix   = "${var.app_name}-${var.environment}"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
  iam_instance_profile        = aws_iam_instance_profile.ecs_service_role.name
  key_name                    = var.key_name
  security_groups             = [aws_security_group.ec2-sg.id]
  associate_public_ip_address = true
  user_data                   = <<EOF
#! /bin/bash
sudo apt-get update
sudo echo "ECS_CLUSTER=${var.cluster_name}" >> /etc/ecs/ecs.config
EOF
}

resource "aws_autoscaling_group" "asg" {
  name                      = "prod-deviceme-asg"
  launch_configuration      = aws_launch_configuration.lc.name
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = var.public_subnets

  target_group_arns     = [aws_lb_target_group.lb_target_group.arn]
  protect_from_scale_in = true
  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_autoscaling_policy" "example-cpu-policy" {
# name = "example-cpu-policy"
# autoscaling_group_name = aws_autoscaling_group.asg.name
# adjustment_type = "ChangeInCapacity"
# scaling_adjustment = "1"
# cooldown = "300"
# policy_type = "SimpleScaling"
# }
# resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm" {
# alarm_name = "example-cpu-alarm"
# alarm_description = "example-cpu-alarm"
# comparison_operator = "GreaterThanOrEqualToThreshold"
# evaluation_periods = "2"
# metric_name = "CPUUtilization"
# namespace = "AWS/EC2"
# period = "120"
# statistic = "Average"
# threshold = "30"
# dimensions = {
# "AutoScalingGroupName" = aws_autoscaling_group.asg.name
# }
# actions_enabled = true
# alarm_actions = ["${aws_autoscaling_policy.example-cpu-policy.arn}"]
# }
# # scale down alarm
# resource "aws_autoscaling_policy" "example-cpu-policy-scaledown" {
# name = "example-cpu-policy-scaledown"
# autoscaling_group_name = aws_autoscaling_group.asg.name
# adjustment_type = "ChangeInCapacity"
# scaling_adjustment = "-1"
# cooldown = "300"
# policy_type = "SimpleScaling"
# }
# resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm-scaledown" {
# alarm_name = "example-cpu-alarm-scaledown"
# alarm_description = "example-cpu-alarm-scaledown"
# comparison_operator = "LessThanOrEqualToThreshold"
# evaluation_periods = "2"
# metric_name = "CPUUtilization"
# namespace = "AWS/EC2"
# period = "120"
# statistic = "Average"
# threshold = "5"
# dimensions = {
# "AutoScalingGroupName" = aws_autoscaling_group.asg.name
# }
# actions_enabled = true
# alarm_actions = ["${aws_autoscaling_policy.example-cpu-policy-scaledown.arn}"]
# }
