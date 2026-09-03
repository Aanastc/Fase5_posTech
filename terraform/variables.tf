variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Região da AWS"
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Ambiente de implantação"
}

variable "db_password" {
  type        = string
  description = "Senha do usuário administrador do banco de dados RDS PostgreSQL"
  sensitive   = true
}