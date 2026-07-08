variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "eks_cluster_security_group_id" {
  description = "Security group ID of the EKS cluster (aws_eks_cluster.this.vpc_config[0].cluster_security_group_id), allowed to reach the DB"
  type        = string
}

variable "admin_username" {
  type    = string
  default = "agritech_admin"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "database_name" {
  type    = string
  default = "agritech"
}

variable "instance_class" {
  description = "e.g. db.t3.micro for dev, db.r6g.large for prod"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
