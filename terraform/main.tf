terraform {
  backend "s3" {
    bucket = "solidarytech-terraform-state-hackathon"
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
# AWS RDS PostgreSQL (Bancos para NGOs e Doacoes)
# -------------------------------------------------------------
resource "aws_security_group" "rds" {
  name        = "solidarytech-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "solidarytech-db-subnet"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "postgres" {
  identifier     = "solidarytech-db"
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = "db.t3.micro"
  allocated_storage = 20

  db_name  = "solidarytech"
  username = "admin"
  password = "SolidaryTech2024"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name  = aws_db_subnet_group.main.name

  skip_final_snapshot = true
  publicly_accessible = false
}

# -------------------------------------------------------------
# Kubernetes (EKS Cluster) nativo
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
# AWS SQS (Mensageria para Doacoes)
# -------------------------------------------------------------
resource "aws_sqs_queue" "donations_queue" {
  name = "solidary-donations"
}

# -------------------------------------------------------------
# AWS DynamoDB (Banco NoSQL para Voluntarios)
# -------------------------------------------------------------
resource "aws_dynamodb_table" "volunteers_table" {
  name           = "SolidaryTechVolunteers"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "volunteer_id"

  attribute {
    name = "volunteer_id"
    type = "S"
  }
}

# -------------------------------------------------------------
# AWS ECR (Repositorios de Imagens Docker)
# -------------------------------------------------------------
resource "aws_ecr_repository" "ngo_service" {
  name                 = "solidarytech/ngo-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

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