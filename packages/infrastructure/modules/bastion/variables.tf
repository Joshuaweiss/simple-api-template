variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "public_key" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "up" {
  type = bool
  default = false
}

variable "ingress_cidrs" {
  type = list(string)
}

variable "user_name" {
  type = string
  default = "bastion"
}

variable "name" {
  type = string
}
