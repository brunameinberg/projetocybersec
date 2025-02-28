#!/bin/bash
set -e  # Para parar em caso de erro

# Atualizando pacotes
apt-get update -y
apt-get upgrade -y

# Instalando Apache, PHP e extensões necessárias para WordPress
apt-get install -y apache2 php php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip php-mysql wget unzip

# Habilitando o mod_rewrite do Apache
a2enmod rewrite

# Instalando Certbot para SSL
apt-get install -y certbot python3-certbot-apache

# Criando configuração do Apache para o domínio
cat <<EOT > /etc/apache2/sites-available/abcplace.conf
<VirtualHost *:80>
    ServerAdmin ${wp_admin_email}
    ServerName abcplace.blog.br
    ServerAlias www.abcplace.blog.br
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        AllowOverride All
    </Directory>

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOT

# Ativar site HTTP e reiniciar Apache
a2dissite 000-default.conf
a2ensite abcplace.conf
systemctl restart apache2

# Parar Apache antes de rodar o Certbot
systemctl stop apache2

# Gerar certificado SSL com Certbot no modo standalone
certbot certonly --standalone --force-renewal --agree-tos -m ${wp_admin_email} -d abcplace.blog.br -d www.abcplace.blog.br


cat <<EOT > /etc/apache2/sites-available/abcplace-ssl.conf
<VirtualHost *:443>
    ServerAdmin ${wp_admin_email}
    ServerName abcplace.blog.br
    ServerAlias www.abcplace.blog.br
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        AllowOverride All
    </Directory>

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/abcplace.blog.br/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/abcplace.blog.br/privkey.pem

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOT

# Ativar SSL no Apache
a2enmod ssl
a2ensite abcplace-ssl.conf
systemctl restart apache2

# Redirecionando HTTP para HTTPS
cat <<EOT > /etc/apache2/sites-available/redirect.conf
<VirtualHost *:80>
    ServerName abcplace.blog.br
    ServerAlias www.abcplace.blog.br
    Redirect permanent / https://abcplace.blog.br/
</VirtualHost>
EOT


# Ativar redirecionamento e reiniciar Apache
a2ensite redirect.conf
systemctl reload apache2


# Baixando e instalando o WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz --strip-components=1
rm latest.tar.gz

# Configurando permissões corretas
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Criando o arquivo wp-config.php
cat <<EOT > /var/www/html/wp-config.php
<?php
define('DB_NAME', 'wordpress_db');
define('DB_USER', '${db_user}');
define('DB_PASSWORD', '${db_password}');
define('DB_HOST', '${db_ip}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
\$table_prefix = 'wp_';

define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOT

# Criando o arquivo .htaccess para garantir que /wp-admin funcione
cat <<EOT > /var/www/html/.htaccess
# BEGIN WordPress
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %$${REQUEST_FILENAME} !-f
RewriteCond %$${REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
# END WordPress
EOT

# Definindo permissões corretas para o .htaccess
chown www-data:www-data /var/www/html/.htaccess
chmod 644 /var/www/html/.htaccess


# Instalando WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Configuração automática do WordPress via WP-CLI
sudo -u www-data wp core install --path="/var/www/html" \
    --url="http://abcplace.blog.br" \
    --title="ABC Place" \
    --admin_user="${wp_admin_user}" \
    --admin_password="${wp_admin_password}" \
    --admin_email="${wp_admin_email}"

# Instalando e ativando WooCommerce automaticamente
sudo -u www-data wp plugin install woocommerce --activate

# Criando as páginas padrão do WooCommerce
sudo -u www-data wp wc tool run install_pages

# Reiniciando Apache para garantir que tudo está rodando corretamente
systemctl restart apache2
