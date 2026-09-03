output "eks_cluster_endpoint" {
  description = "Endpoint do plano de controle do EKS"
  value       = aws_eks_cluster.cluster.endpoint
}

output "eks_cluster_name" {
  description = "Nome do cluster EKS criado"
  value       = aws_eks_cluster.cluster.name
}

output "sqs_queue_url" {
  description = "URL da fila do SQS de doações"
  value       = aws_sqs_queue.donations_queue.url
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  value       = aws_dynamodb_table.volunteers_table.name
}

output "rds_endpoint" {
  description = "Endpoint do RDS PostgreSQL"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_address" {
  description = "Endereco do RDS PostgreSQL"
  value       = aws_db_instance.postgres.address
}
