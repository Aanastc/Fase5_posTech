#!/bin/bash
# Cria bucket S3 automaticamente com nome dinamico baseado no AWS Account ID

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="solidarytech-tf-state-${ACCOUNT_ID}"
REGION="us-east-1"

echo "Verificando bucket: ${BUCKET_NAME}"

if aws s3api head-bucket --bucket "${BUCKET_NAME}" --region "${REGION}" 2>/dev/null; then
    echo "Bucket ${BUCKET_NAME} ja existe."
else
    echo "Criando bucket ${BUCKET_NAME}..."
    aws s3api create-bucket --bucket "${BUCKET_NAME}" --region "${REGION}"
    echo "Bucket criado com sucesso!"
fi

echo "Atualize terraform/main.tf com: bucket = \"${BUCKET_NAME}\""