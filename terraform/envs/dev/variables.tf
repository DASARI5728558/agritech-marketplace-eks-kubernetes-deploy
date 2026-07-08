variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "azs" {
  description = "Availability zones, e.g. [\"ap-south-1a\", \"ap-south-1b\"]"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "mysql_admin_password" {
  description = "Master password for the RDS MySQL instance"
  type        = string
  sensitive   = true
}
