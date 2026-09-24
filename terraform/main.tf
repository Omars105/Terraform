terraform {
  required_version = ">1.2.0"
  backend "s3" {
    bucket = "omars-tf-state-bucket"
    key = "terraform.tfstate"
    region = "us-east-1"
  }

}


provider "aws" {
  region = var.region
  # Credentials are loaded from environment variables or AWS CLI (~/.aws/credentials)
  # Never hardcode access_key and secret_key here!
}




resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    Name: "${var.env-prefix}-vpc"
  }

}

resource "aws_subnet" "myapp-subnet" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet-cidr-block
  availability_zone = var.availability-zone
  tags = {
    Name: "${var.env-prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name: "${var.env-prefix}-igw"
  }
}


resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env-prefix}-main-rtb"
  }
}



resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id
  
  ingress {
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = [] 
  }
tags = {
  Name: "${var.env-prefix}-default-sg"
}

}

data "aws_ami" "latest-amazon-linux" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

output "ec2-public-ip" {
  value = aws_instance.myapp-server.public_ip
}


resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.availability-zone
  associate_public_ip_address = true
  key_name = "myapp-key-pair"

  user_data = file("entry-script.sh")

 user_data_replace_on_change = true
  
  

  tags = {
    Name: "${var.env-prefix}-server"
  }

}