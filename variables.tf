variable "key_name" {
  type        = string
  description = "The name for ssh key, used for aws_launch_configuration"
}

variable "cluster_name" {
  type        = string
  description = "The name of AWS ECS cluster"
}

variable "public_subnets" {
  type = list(any)
}
variable "vpc_id" {
  type = string
}
variable "load_balancer_arn" {
  type = string
}

variable "domain_name" {
  description = "app domain name"
  type        = string
}

variable "root_domain_name" {
  description = "Hosted zone name"
  type        = string
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
}
variable "nginx_image" {
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}
