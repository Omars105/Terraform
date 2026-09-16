resource "aws_subnet" "myapp-subnet" {
  vpc_id = var.vpc-id
  cidr_block = var.subnet-cidr-block
  availability_zone = var.availability-zone
  tags = {
    Name: "${var.env-prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.vpc-id
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
  default_route_table_id = var.default-route-table-id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env-prefix}-main-rtb"
  }
}