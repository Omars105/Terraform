provider "aws" {
  region = "eu-north-1"
  # Credentials are loaded from environment variables or AWS CLI (~/.aws/credentials)
  # Never hardcode access_key and secret_key here!
}

variable "cidr-blocks" {
  description = "The cidr block for the first subnet"
  type = list(string)
}


resource "aws_vpc" "terraform-vpc" {
  cidr_block = var.cidr-blocks[0]
  tags = {
    Name: "terraform-vpc"
  }

}

resource "aws_subnet" "terraform-subnet" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = var.cidr-blocks[1]
  availability_zone = "eu-north-1a"
  tags = {
    Name: "terraform-subnet"
  }
}

data "aws_vpc" "existing-vpc" {
  default = true
}

resource "aws_subnet" "terraform-subnet2" {
  vpc_id = data.aws_vpc.existing-vpc.id
  cidr_block = "172.31.48.0/20"
  availability_zone = "eu-north-1a"
  tags = {
    Name: "terraform-subnet2"
  }
}

output "tf-vpc-id" {
  value = aws_vpc.terraform-vpc.id
}

output "tf-subnet-id" {
  value = aws_subnet.terraform-subnet.id
}