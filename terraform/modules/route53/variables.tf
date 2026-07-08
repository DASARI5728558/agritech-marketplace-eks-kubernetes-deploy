variable "dns_zone_name" {
  description = "Root DNS zone, e.g. agritech-marketplace.com"
  type        = string
}

variable "create_zone" {
  description = "Set to true to create a new hosted zone, false to use an existing one"
  type        = bool
  default     = true
}

variable "record_name" {
  description = "Subdomain record, e.g. 'www' or 'app'"
  type        = string
  default     = "www"
}

variable "load_balancer_dns_name" {
  description = "DNS name of the AWS Load Balancer created by the ingress controller (from 'kubectl get svc -n ingress-nginx')"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
