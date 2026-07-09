variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "capacity_type" {
  description = "ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 4
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "github_actions_role_arn" {
  description = "ARN of the IAM role used by GitHub Actions CI/CD (e.g. arn:aws:iam::<account-id>:role/github-actions-agritech-role). Leave empty (\"\") to skip granting access automatically."
  type        = string
  default     = ""
}
