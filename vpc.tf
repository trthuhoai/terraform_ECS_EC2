# module "vpc" {
#   source         = "terraform-aws-modules/vpc/aws"
#   version        = "2.58.0"
#   name           = "msy_ecs_provisioning_pro"
#   cidr           = "10.0.0.0/16"
#   azs            = ["us-east-1a", "us-east-1c", "us-east-1b"]
#   public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.4.0/24"]
#   enable_dns_hostnames="true"
#   tags = {
#     "env"       = "dev"
#     "createdBy" = "mkerimova"
#   }

# }

data "aws_vpc" "main" {
  id = var.vpc_id
}