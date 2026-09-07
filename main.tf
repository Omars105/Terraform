provider "aws" {
  region = "eu-north-1"
  # Credentials are loaded from environment variables or AWS CLI (~/.aws/credentials)
  # Never hardcode access_key and secret_key here!
}

variable "vpc-cidr-block" {}
variable "subnet-cidr-block" {}
variable "availability-zone" {}
variable "env-prefix" {}
variable "my-ip" {}
variable "instance_type" {}
variable "ssh-public-key-location" {}


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

/*resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env-prefix}-rtb"
  }
}

resource "aws_route_table_association" "myapp-rtb-association" {
  subnet_id      = aws_subnet.myapp-subnet.id
  route_table_id = aws_route_table.myapp-route-table.id
}*/

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

/*resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id
  
  ingress {
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = [var.my-ip]
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
  Name: "${var.env-prefix}-sg"
}

}
*/

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id
  
  ingress {
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = [var.my-ip]
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

output "aws-ami-id" {
value = data.aws_ami.latest-amazon-linux.id

}

output "ec2-public-ip" {
  value = aws_instance.myapp-server.public_ip
}

resource "aws_key_pair" "ssh-key" {
  key_name = "ssh-key"
  public_key = file(var.ssh-public-key-location)
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.availability-zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")

 user_data_replace_on_change = true
  
  

  tags = {
    Name: "${var.env-prefix}-server"
  }

}