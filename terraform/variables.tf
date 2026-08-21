variable "aws_region" {
  description = "A região da AWS onde a infraestrutura será criada"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (ex: Production, Staging, Dev)"
  type        = string
  default     = "Production"
}
