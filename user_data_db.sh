#!/bin/bash
set -e

# Atualizando pacotes e instalando MySQL
sudo apt update -y
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql

# Criando banco de dados e usuário com variáveis seguras
sudo mysql -e "CREATE DATABASE wordpress_db;"
sudo mysql -e "CREATE USER '${db_user}'@'%' IDENTIFIED BY '${db_password}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO '${db_user}'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Permitindo conexões remotas
sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
