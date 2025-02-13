resource "aws_instance" "ABCplace_instancia_aplicacao" {
  ami                    = "ami-04b4f1a9cf54c11d0" 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ABCplace_public_subnet.id
  vpc_security_group_ids = [aws_security_group.ABCplace_sg.id]
  key_name               = aws_key_pair.terraform_key.key_name  

  user_data = <<-EOF
              #!/bin/bash
              # Atualizando o sistema
              sudo apt update -y
              sudo apt upgrade -y

              # Instalando o Apache e o PHP
              sudo apt install apache2 php php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y
              
              sudo mkdir -p /var/www/abcplace

              echo '<VirtualHost *:80>
                  ServerAdmin admin@abcplace.com
                  ServerName abcplace.com
                  ServerAlias www.abcplace.com
                  DocumentRoot /var/www/abcplace

                  <Directory /var/www/abcplace>
                      AllowOverride All
                  </Directory>

                  ErrorLog \$\{APACHE_LOG_DIR}/error.log
                  CustomLog \$\{APACHE_LOG_DIR}/access.log combined
              </VirtualHost>' | sudo tee /etc/apache2/sites-available/abcplace.conf

              # Ativar o site e o módulo rewrite
              sudo a2ensite abcplace.conf
              sudo a2enmod rewrite
              sudo systemctl restart apache2

              # Baixar e instalar o WordPress
              cd /var/www/abcplace
              sudo wget https://wordpress.org/latest.tar.gz
              sudo tar -xvzf latest.tar.gz --strip-components=1
              sudo chown -R www-data:www-data /var/www/abcplace
              sudo chmod -R 755 /var/www/abcplace

              # Reiniciar o Apache
              sudo systemctl restart apache2
              EOF
  tags = {
    Name = "ABCplace_instancia_aplicacao"
  }
}
