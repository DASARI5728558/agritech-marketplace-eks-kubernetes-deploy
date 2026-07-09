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
    bucket = "agritech-tfstate-prod"
    key    = "prod/terraform.tfstate"
    region = "ap-south-1"
    # Recommended: enable a DynamoDB table for state locking
    # dynamodb_table = "agritech-tfstate-lock-prod"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix  = "agritech-prod"
  cluster_name = "agritech-prod-eks"
  tags = {
    project     = "agritech-marketplace"
    environment = "prod"
    managed_by  = "terraform"
  }
}

module "vpc" {
  source       = "../../modules/vpc"
  name_prefix  = local.name_prefix
  cluster_name = local.cluster_name
  vpc_cidr     = "10.20.0.0/16"
  azs          = var.azs
  public_subnet_cidrs  = ["10.20.0.0/24", "10.20.1.0/24"]
  private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]
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
  instance_types      = ["t3.large"]
  capacity_type       = "ON_DEMAND"
  desired_size        = 3
  min_size            = 3
  max_size            = 10
  tags                = local.tags
  github_actions_role_arn = var.github_actions_role_arn
}

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
  instance_class                 = "db.r6g.large"
  allocated_storage              = 100
  multi_az                       = true
  deletion_protection            = true
  skip_final_snapshot            = false
  database_name                  = "agritech_prod"
  tags                            = local.tags
}

# Route53 record pointing at the ingress controller's Load Balancer.
# Populate var.load_balancer_dns_name AFTER the ingress-nginx (or ALB) controller
# is installed and has provisioned its LoadBalancer service.
module "route53" {
  source                  = "../../modules/route53"
  dns_zone_name            = var.dns_zone_name
  create_zone              = var.create_dns_zone
  record_name              = "www"
  load_balancer_dns_name   = var.load_balancer_dns_name
  tags                     = local.tags
}
