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
# Kubernetes (EKS Cluster) nativo - Evita erros do AWS Academy
# -------------------------------------------------------------
resource "aws_eks_cluster" "cluster" {
  name     = "solidarytech-cluster"
  version  = "1.28"
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  vpc_config {
    subnet_ids              = module.vpc.private_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

resource "aws_eks_node_group" "spot_nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "spot_nodes"
  node_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  subnet_ids      = module.vpc.private_subnets
  capacity_type   = "SPOT"
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
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
