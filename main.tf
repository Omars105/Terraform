provider "aws" {
  region = "eu-north-1"
  # Credentials are loaded from environment variables or AWS CLI (~/.aws/credentials)
  # Never hardcode access_key and secret_key here!
}




resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    Name: "${var.env-prefix}-vpc"
  }

}


module "myapp-subnet" {
  source = "./modules/subnet"
  subnet-cidr-block = var.subnet-cidr-block
  availability-zone = var.availability-zone
  env-prefix = var.env-prefix
  vpc-id = aws_vpc.myapp-vpc.id
  default-route-table-id = aws_vpc.myapp-vpc.default_route_table_id
}


module "webserver" {
  source = "./modules/webserver"
  subnet-id = module.myapp-subnet.subnet.id
  availability-zone = var.availability-zone
  env-prefix = var.env-prefix
  vpc-id = aws_vpc.myapp-vpc.id
  ssh-public-key-location = var.ssh-public-key-location
  image-name = var.image-name
  my-ip = var.my-ip
  instance_type = var.instance_type
}