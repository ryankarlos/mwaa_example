# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}



locals {
  azs         = slice(data.aws_availability_zones.available.names, 0, 2)
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.1"
  
  name = "mwaa-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}