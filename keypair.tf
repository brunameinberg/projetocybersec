resource "tls_private_key" "ABCplace_chave_ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "terraform_key" {
  key_name   = "ABCplace_keypair"  
  public_key = tls_private_key.ABCplace_chave_ssh.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.ABCplace_chave_ssh.private_key_pem
  filename = "${path.module}/ABCplace_keypair.pem"
  file_permission = "0400"  
}

