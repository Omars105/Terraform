provider "aws" {
  region = "eu-north-1"
}

variable "vpc-cidr-block" {}
variable "private_subnet-cidr-block" {}
variable "public-subnet-cidr-block" {}

data "aws_availability_zones" "azs" {


}



module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.2"

  name = "myapp-vpc"
  cidr = var.vpc-cidr-block
  private_subnets = var.private_subnet-cidr-block
  public_subnets = var.public-subnet-cidr-block
  azs = data.aws_availability_zones.azs.names

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  tags ={
    Name = "myapp-vpc"
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }


}

