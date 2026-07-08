output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_backend_repo_url" {
  value = module.ecr.backend_repository_url
}

output "ecr_frontend_repo_url" {
  value = module.ecr.frontend_repository_url
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "dns_name_servers" {
  value = module.route53.name_servers
}

output "app_fqdn" {
  value = module.route53.fqdn
}
