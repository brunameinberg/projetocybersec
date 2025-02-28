# 🚀 Projeto: Infraestrutura Segura para WordPress na AWS com Cloudflare WAF

## 📌 Visão Geral
Este projeto configura automaticamente um servidor WordPress seguro na AWS utilizando Terraform. Além disso, o Cloudflare WAF é configurado para proteger contra ataques como DDoS, SQL Injection e Força Bruta.


## 📂 Estrutura do Projeto
```bash
📁 projetocybersec
│── 📄 keypair.tf           # Criação da Keypair 
│── 📄 main.tf              # Instâncias (frontend e database)
│── 📄 output.tf            # Dados que mostrarão no terminal após o terraform apply
│── 📄 security_group.tf    # Grupos de segurança
│── 📄 vpc.tf               # Configuração da VPC, Subnets e Gateways
│── 📄 variables.tf         # Variáveis sensíveis (segurança)
│── 📄 terraform.tfvars     # Valores das variáveis (NÃO versionar no Git)
│── 📄 user_data.sh         # Script de inicialização do servidor WordPress
│── 📄 user_data_db.sh      # Script de inicialização do servidor MySQL
│── 📄 README.md            # Documentação do projeto
│── 📄 .gitignore           # Ignorar arquivos sensíveis no repositório

```

## 🛠 Tecnologias Utilizadas
- **AWS**
    - EC2 (Instância do WordPress e Banco de Dados)
    - VPC (Subnets Públicas e Privadas)
    - Security Groups (Firewall na AWS)
    - NAT Gateway (Permitir internet para a subnet privada)
- **Terraform** (Infraestrutura como Código)
- **Cloudflare WAF** (Proteção contra ataques)
- **WordPress** + WooCommerce
- **Certbot** (SSL gratuito com Let's Encrypt)

## ☁️ Infraestrutura AWS
O Terraform cria a seguinte infraestrutura:

1. **VPC (Rede Privada)**

    - 1 Subnet Pública (para a aplicação WordPress)
    - 1 Subnet Privada (para o banco de dados)
    - 1 NAT Gateway (para permitir que a instância do banco tenha acesso à internet para updates)

2. **EC2 (Máquinas Virtuais)**

    - 1 Instância EC2 (Ubuntu) rodando o WordPress
    - 1 Instância EC2 (Ubuntu) rodando o MySQL

3. **Security Groups (Regras de Firewall)**

    - Permitir acesso público apenas na porta 80 e 443 (Web e HTTPS)
    - Restringir acesso ao banco de dados (MySQL) apenas à aplicação
    - SSH permitido somente de IPs confiáveis (Evitar ataques externos)


## 📜 Como Utilizar o Projeto?
Após clonar o repositório em sua máquina:

### 1️⃣ Pré-requisitos

Antes de iniciar, você precisa ter instalado:

- **Terraform** (```terraform -v```)
- **AWS CLI** (```aws --version```)
- **Cloudflare Account** (configurar domínio)

### 2️⃣ Configurar as credenciais AWS

```bash
aws configure
```

**Preencha com sua Access Key e Secret Key da AWS.**

### 3️⃣ Inicializar e Criar Infraestrutura

- Altere o domínio no user_data (opcional caso deseje usar o domínio)
- Crie as varíáveis no arquivo ```terraform.tfvars```:
```t
db_user = ""
db_password = ""

wp_admin_user = ""
wp_admin_password = ""
wp_admin_email = ""

```

- Utilizando terraform, crie a estrutura

```bash

terraform init
terraform plan
terraform apply -var-file="terraform.tfvars" #Arquivo que as variáveis estão escondidas
```

### 4️⃣ Configurar o Cloudflare (opcional caso deseje configurar o dominio)
- No Cloudflare, adicione seu domínio, no meu caso, abcplace.blog.br
- Aponte os Nameservers para os fornecidos pelo Cloudflare.
- Esse domínio precisa estar registrado

#### 🔒 Configuração do WAF no Cloudflare

O WAF da Cloudflare protege o site contra ameaças como DDoS, SQL Injection e Ataques de Força Bruta.

##### 🚨 Regras de Segurança Aplicadas

- **1️⃣Bloquear acessos de IPs fora do Brasil**

    - 🔒 **Regra:** Permitir apenas acessos do Brasil (Country == Brasil)
    - 📍 **Motivo:** Restringir acessos internacionais não autorizados

- **2️⃣ 🔹 Rate Limiting para /wp-admin**

    - 🔒 **Regra:** Bloquear IPs após 5 tentativas em 1 minuto
    - 📍 **Motivo:** Prevenir ataques de força bruta

- **3️⃣ 🔹 Bloquear SQL Injection**

    - 🔒 **Regra:** Se Request URI contém "UNION SELECT" ou "--", bloquear
    - 📍 **Motivo:** Evitar ataques que tentam roubar dados do banco

- **4️⃣ 🔹 Proteção contra DDoS**

    - 🔒 **Regra:** Se um IP fizer mais de 1000 requisições por minuto, bloquear
    - 📍 **Motivo:** Prevenir sobrecarga do servidor

- **5️⃣ 🔹 Bloquear bots suspeitos**

    - 🔒 **Regra:** Se Known Bots == verdadeiro, bloquear
    - 📍 **Motivo:** Reduzir spam e ataques automatizados


## ⚠️ Considerações de Segurança
- Nunca exponha credenciais no código (terraform.tfvars está no .gitignore).
- Acompanhe logs no Cloudflare para monitorar acessos suspeitos.

## 👨‍💻 Autora
🔹 Bruna MEinberg
📧 Email: brunamein@gmail.com
🔗 LinkedIn: https://www.linkedin.com/in/brunameinberg/