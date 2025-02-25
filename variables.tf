variable "db_user" {
  description = "Usuário do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "wp_admin_user" {
  description = "Usuário administrador do WordPress"
  type        = string
  sensitive   = true
}

variable "wp_admin_password" {
  description = "Senha do administrador do WordPress"
  type        = string
  sensitive   = true
}

variable "wp_admin_email" {
  description = "E-mail do administrador do WordPress"
  type        = string
}
