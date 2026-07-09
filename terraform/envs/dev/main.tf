terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "agritech-tfstate-dev"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
    # Recommended: enable a DynamoDB table for state locking
    # dynamodb_table = "agritech-tfstate-lock-dev"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix  = "agritech-dev"
  cluster_name = "agritech-dev-eks"
  tags = {
    project     = "agritech-marketplace"
    environment = "dev"
    managed_by  = "terraform"
  }
}

module "vpc" {
  source       = "../../modules/vpc"
  name_prefix  = local.name_prefix
  cluster_name = local.cluster_name
  vpc_cidr     = "10.10.0.0/16"
  azs          = var.azs
  public_subnet_cidrs  = ["10.10.0.0/24", "10.10.1.0/24"]
  private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]
  tags = local.tags
}

module "ecr" {
  source      = "../../modules/ecr"
  name_prefix = local.name_prefix
  tags        = local.tags
}

module "eks" {
  source              = "../../modules/eks"
  name_prefix         = local.name_prefix
  cluster_name        = local.cluster_name
  kubernetes_version  = "1.29"
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  instance_types      = ["t3.medium"]
  capacity_type       = "ON_DEMAND"
  desired_size        = 2
  min_size            = 1
  max_size            = 4
  tags                = local.tags
  github_actions_role_arn = var.github_actions_role_arn
}

# EKS's auto-created cluster security group, used to allow node -> RDS traffic
data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

module "rds" {
  source                         = "../../modules/rds"
  name_prefix                    = local.name_prefix
  vpc_id                         = module.vpc.vpc_id
  db_subnet_group_name           = module.vpc.db_subnet_group_name
  eks_cluster_security_group_id  = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  admin_password                 = var.mysql_admin_password
  instance_class                 = "db.t3.micro"
  allocated_storage              = 20
  multi_az                       = false
  database_name                  = "agritech_dev"
  tags                            = local.tags
}
