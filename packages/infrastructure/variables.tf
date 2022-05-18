variable "cidr" {
  type = string
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "aws_azs" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1e"]
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "up" {
  type = bool
  default = true
}

variable "home_ips" {
  type = list(string)
  default = []
}
