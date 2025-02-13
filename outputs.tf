output "public_ip" {
  value = aws_instance.ABCplace_instancia_aplicacao.public_ip
}

output "vpc_id" {
  value = aws_vpc.ABCplace_vpc.id
}

output "subnet_id" {
  value = aws_subnet.ABCplace_public_subnet.id
}
