resource "aws_security_group" "ABCplace_sg" {
  vpc_id = aws_vpc.ABCplace_vpc.id
  name   = "ABCplace_SecurityGroup"

  # SSH (porta 22) - descomentar caso necessário. para mais segurança, colocar o prórpio ip
  #ingress {
  #  from_port   = 22
  #  to_port     = 22
  #  protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]  
  #}

  # Apache
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ABCplace_SecurityGroup"
  }
}

resource "aws_security_group" "ABCplace_db_sg" {
  vpc_id = aws_vpc.ABCplace_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ABCplace_sg.id]
  }

  # SSH (porta 22) - descomentar caso necessário. para mais segurança, colocar o prórpio ip
  #ingress {
  #  from_port   = 22
  #  to_port     = 22
  #  protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]  
  #}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ABCplace_DB_SG"
  }
}

