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

#database subnet
resource "aws_subnet" "ABCplace_db_subnet" {
  vpc_id                  = aws_vpc.ABCplace_vpc.id
  cidr_block              = "10.0.2.0/24"  

  tags = {
    Name = "ABCplace_DB_Subnet"
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

# Elastic IP para o NAT Gateway
resource "aws_eip" "ABCplace_nat_eip" {
  domain = "vpc"
}

# NAT Gateway para dar acesso à internet para a subnet privada
resource "aws_nat_gateway" "ABCplace_nat_gw" {
  allocation_id = aws_eip.ABCplace_nat_eip.id
  subnet_id     = aws_subnet.ABCplace_public_subnet.id  # NAT fica na subnet pública

  tags = {
    Name = "ABCplace_NAT_Gateway"
  }
}

# Route table para a subnet privada (DB) usar o NAT Gateway
resource "aws_route_table" "ABCplace_db_route_table" {
  vpc_id = aws_vpc.ABCplace_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ABCplace_nat_gw.id
  }

  tags = {
    Name = "ABCplace_DB_Route_Table"
  }
}

resource "aws_route_table_association" "ABCplace_db_rta" {
  subnet_id      = aws_subnet.ABCplace_db_subnet.id
  route_table_id = aws_route_table.ABCplace_db_route_table.id
}
