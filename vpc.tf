# VPC
resource "aws_vpc" "ABCplace_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ABCplace_vpc"
  }
}

# Public subnet
resource "aws_subnet" "ABCplace_public_subnet" {
  vpc_id                  = aws_vpc.ABCplace_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "ABCplace_public_subnet"
  }
}

# Gateway
resource "aws_internet_gateway" "ABCplace_igw" {
  vpc_id = aws_vpc.ABCplace_vpc.id

  tags = {
    Name = "ABCplace_igw"
  }
}

resource "aws_route_table" "ABCplace_route_table" {
  vpc_id = aws_vpc.ABCplace_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ABCplace_igw.id
  }

  tags = {
    Name = "ABCplace_routetable"
  }
}

resource "aws_route_table_association" "ABCplace_rta_subnet" {
    subnet_id      = aws_subnet.ABCplace_public_subnet.id
    route_table_id = aws_route_table.ABCplace_route_table.id
}
