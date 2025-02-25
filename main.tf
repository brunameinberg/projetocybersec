resource "aws_instance" "ABCplace_instancia_aplicacao" {
  ami                    = "ami-04b4f1a9cf54c11d0" 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ABCplace_public_subnet.id
  vpc_security_group_ids = [aws_security_group.ABCplace_sg.id]
  key_name               = aws_key_pair.terraform_key.key_name  

 user_data = templatefile("${path.module}/user_data.sh", {
    db_ip = aws_instance.ABCplace_db_instance.private_ip
    db_user    = var.db_user
    db_password = var.db_password
    wp_admin_user    = var.wp_admin_user
    wp_admin_password = var.wp_admin_password
    wp_admin_email   = var.wp_admin_email
  })
  tags = {
    Name = "ABCplace_instancia_aplicacao"
  }
}

resource "aws_instance" "ABCplace_db_instance" {
  ami                    = "ami-04b4f1a9cf54c11d0"  
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ABCplace_db_subnet.id
  vpc_security_group_ids = [aws_security_group.ABCplace_db_sg.id]
  key_name               = aws_key_pair.terraform_key.key_name

  user_data = templatefile("${path.module}/user_data_db.sh", {
    db_user     = var.db_user
    db_password = var.db_password
  })

  depends_on = [
    aws_nat_gateway.ABCplace_nat_gw,
    aws_route_table_association.ABCplace_db_rta
  ]

  tags = {
    Name = "ABCplace_instancia_database"
  }
}
