resource "aws_default_security_group" "default-sg" {
  vpc_id = var.vpc-id
  
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
    Name = "${var.env-prefix}-default-sg"
  }

}

data "aws_ami" "latest-amazon-linux" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = [var.image-name]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}



resource "aws_key_pair" "ssh-key" {
  key_name = "ssh-key"
  public_key = file(var.ssh-public-key-location)
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux.id
  instance_type = var.instance_type
  subnet_id = var.subnet-id
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