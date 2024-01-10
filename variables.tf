variable "key_name" {
  type        = string
  description = "The name for ssh key, used for aws_launch_configuration"
  default     = "test-ec2-key"
}

variable "cluster_name" {
  type        = string
  description = "The name of AWS ECS cluster"
  default     = "Prod-DeviceMe-Api"
}

variable "public_subnets" {
  type = list(any)
  default = [
    "subnet-0b9073b46975b82c7",
    "subnet-0776f9772c3985c39"
  ]
}
variable "vpc_id" {
  type    = string
  default = "vpc-0a785a6b23587e256"
}
variable "load_balancer_arn" {
  type    = string
  default = "arn:aws:elasticloadbalancing:us-east-1:781389222027:loadbalancer/app/msy-backend/b610d6dd06ffb096"
}

variable "domain_name" {
  default     = "ec.thuhoai.top"
  description = "app domain name"
  type        = string
}

variable "root_domain_name" {
  default     = "thuhoai.top"
  description = "Hosted zone name"
  type        = string
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "043749410616.dkr.ecr.us-east-1.amazonaws.com/app-mullion:latest"
}
variable "nginx_image" {
  default = "043749410616.dkr.ecr.us-east-1.amazonaws.com/web-mullion:latest"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "value"
}

variable "environment" {
  type    = string
  default = "dev"
}
