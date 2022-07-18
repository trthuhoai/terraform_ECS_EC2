module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  version        = "2.58.0"
  name           = "msy_ecs_provisioning"
  cidr           = "10.0.0.0/16"
  azs            = ["ap-southeast-1a", "ap-southeast-1c", "ap-southeast-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.4.0/24"]
  tags = {
    "env"       = "dev"
    "createdBy" = "mkerimova"
  }

}

data "aws_vpc" "main" {
  id = module.vpc.vpc_id
}