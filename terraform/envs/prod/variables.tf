variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}

variable "dns_zone_name" {
  description = "Root DNS zone for the production site, e.g. agritech-marketplace.com"
  type        = string
}

variable "create_dns_zone" {
  description = "Set false if the hosted zone already exists in Route53"
  type        = bool
  default     = true
}

variable "load_balancer_dns_name" {
  description = "DNS name of the Load Balancer created by the ingress controller (get this after first apply + ingress install, then re-apply)"
  type        = string
  default     = ""
}
