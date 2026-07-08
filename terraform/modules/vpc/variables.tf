variable "name_prefix" {
  description = "Prefix used for naming resources"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name (used for subnet tags required by the AWS Load Balancer Controller)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across, e.g. [\"us-east-1a\", \"us-east-1b\"]"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ) - used by EKS nodes and RDS"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
