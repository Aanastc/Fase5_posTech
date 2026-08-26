terraform {
  backend "s3" {
    bucket = "solidarytech-terraform-state-hackathon" # VOCÊ PRECISA CRIAR ESSE BUCKET NA AWS ANTES!
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Tags obrigatórias do Hackathon aplicadas em todos os recursos gerados pelo Terraform
  default_tags {
    tags = {
      Project     = "SolidaryTech"
      Environment = var.environment
      CostCenter  = "NGO-Core"
    }
  }
}

data "aws_caller_identity" "current" {}

# -------------------------------------------------------------
# VPC e Redes (Base)
# -------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "solidarytech-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# -------------------------------------------------------------
# Kubernetes (EKS Cluster)
# -------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "solidarytech-cluster"
  cluster_version = "1.28"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Desabilita o aws-auth configmap para contornar o erro de iam:GetRole (AccessDenied) no AWS Academy
  manage_aws_auth_configmap = false

  # No AWS Academy, não podemos criar Roles novas (iam:CreateRole é bloqueado)
  # Portanto, somos obrigados a usar a LabRole que já vem pré-criada na conta.
  create_iam_role = false
  iam_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  eks_managed_node_groups = {
    spot_nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT" # Otimização de custo (FinOps)

      # Usa a mesma LabRole para as máquinas worker nodes
      create_iam_role = false
      iam_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
    }
  }
}

# -------------------------------------------------------------
# AWS SQS (Mensageria para Doações)
# -------------------------------------------------------------
resource "aws_sqs_queue" "donations_queue" {
  name = "solidary-donations"
}

# -------------------------------------------------------------
# AWS DynamoDB (Banco NoSQL para Voluntários)
# -------------------------------------------------------------
resource "aws_dynamodb_table" "volunteers_table" {
  name           = "SolidaryTechVolunteers"
  billing_mode   = "PAY_PER_REQUEST" # Economia de custos em ambientes sem tráfego previsível
  hash_key       = "volunteer_id"

  attribute {
    name = "volunteer_id"
    type = "S"
  }
}

# -------------------------------------------------------------
# AWS ECR (Repositórios de Imagens Docker)
# -------------------------------------------------------------
resource "aws_ecr_repository" "ngo_service" {
  name                 = "solidarytech/ngo-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Permite deletar o ECR com imagens (facilita pro Hackathon)

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "donation_service" {
  name                 = "solidarytech/donation-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "volunteer_service" {
  name                 = "solidarytech/volunteer-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
