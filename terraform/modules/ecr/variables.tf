variable "name_prefix" {
  description = "Prefix used for naming resources"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
